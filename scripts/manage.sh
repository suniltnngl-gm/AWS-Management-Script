
#!/bin/bash
# Master automation script for AWS-Management-Script
# Usage: ./scripts/manage.sh [build|test|deploy|evaluate|all] [--env ENV] [--dry-run] [--verbose]

set -e

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../tools/utils.sh"

usage() {
  echo "Usage: $0 [build|test|deploy|evaluate|all|batch|changed|ai-report] [--env ENV] [--dry-run] [--verbose] [--since COMMIT] [--pattern GLOB] [--help|-h]"
  echo "  build       Build the project"
  echo "  test        Run integration tests"
  echo "  deploy      Deploy to AWS"
  echo "  evaluate    Analyze AWS usage"
  echo "  all         Run all steps in sequence"
  echo "  batch       Batch AI/automation command for changed files"
  echo "  changed     List changed files since commit"
  echo "  ai-report   Summarize AI token/credit usage"
  echo "  --env ENV   Specify environment (default: default)"
  echo "  --dry-run   Show commands without executing"
  echo "  --verbose   Enable verbose logging"
  echo "  --since COMMIT  Only consider files changed since COMMIT (default: HEAD)"
  echo "  --pattern GLOB  Only consider files matching GLOB (default: *)"
  echo "  --help, -h  Show this help message"
  exit 0
}

if [[ $# -eq 0 || $1 == "--help" || $1 == "-h" ]]; then
  usage
fi

ACTION=$1
shift


ENV="default"
DRY_RUN=false
VERBOSE=false
SINCE="HEAD"
PATTERN="*"
BATCH_CMD=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENV="$2"; shift 2;;
    --dry-run)
      DRY_RUN=true; shift;;
    --verbose)
      VERBOSE=true; shift;;
    --since)
      SINCE="$2"; shift 2;;
    --pattern)
      PATTERN="$2"; shift 2;;
    --batch)
      BATCH_CMD="$2"; shift 2;;
    *)
      shift;;
  esac
done

run_step() {
  CMD=$1
  if [ "$DRY_RUN" = true ]; then
    log_info "Dry run: $CMD"
  else
    log_info "Running: $CMD"
    eval $CMD
  fi
}

case $ACTION in
  build)
    run_step "../build.sh --env $ENV"
    ;;
  test)
    run_step "../tools/integration_runner.sh --env $ENV"
    ;;
  deploy)
    run_step "../deploy.sh --env $ENV"
    ;;
  evaluate)
    run_step "../tools/aws_usage.sh --env $ENV"
    ;;
  all)
    run_step "../build.sh --env $ENV"
    run_step "../tools/integration_runner.sh --env $ENV"
    run_step "../deploy.sh --env $ENV"
    run_step "../tools/aws_usage.sh --env $ENV"
    ;;
  changed)
    ./scripts/changed_files.sh --since "$SINCE" --pattern "$PATTERN"
    ;;
  batch)
    CHANGED_FILES=$(./scripts/changed_files.sh --since "$SINCE" --pattern "$PATTERN")
    if [[ -n "$BATCH_CMD" && -n "$CHANGED_FILES" ]]; then
      ./scripts/ai_batch_request.sh "$BATCH_CMD" $CHANGED_FILES
      # After batch edit, export and encrypt chat for secure cloudshell access
      SUMMARY="Batch edit: $BATCH_CMD on $CHANGED_FILES"
      CHAT_EXPORT=$(./tools/save_chat.sh "$SUMMARY" | grep 'Chat saved:' | awk '{print $3}')
      if [[ -n "$CHAT_EXPORT" && -f "$CHAT_EXPORT" ]]; then
        log_info "Chat export complete: $CHAT_EXPORT (move to private_docs/ and archive with tools/private_docs_zip.sh if needed)"
      fi
    else
      log_info "No changed files or batch command specified."
    fi
    ;;
  ai-report)
    ./scripts/ai_token_usage.sh
    ;;
  *)
    usage
    ;;
