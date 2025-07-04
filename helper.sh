
#!/bin/bash
# Single entry point for all project actions: repo, workflow, cloud, ai, workspace
set -e

SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0")"
PROJECT_ROOT="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

usage() {
  echo "Usage: $0 <category> <action> [args...]"
  echo "Categories: repo, workflow, cloud, ai, workspace"
  echo "Workflow actions: build, test, deploy, evaluate, all, changed, batch, ai-report"
  echo "Examples:"
  echo "  $0 workflow build"
  echo "  $0 repo status"
  echo "  $0 ai analyze-ci-log"
  echo "  $0 workspace config"
  exit 1
}

if [[ $# -eq 0 || $1 == --help || $1 == -h ]]; then
  usage
fi

case $1 in
  repo)
    case $2 in
      status) git status ;;
      log) git log --oneline --graph --decorate --all ;;
      pull) git pull ;;
      push) git push ;;
      clone) git clone "$3" ;;
      *) usage ;;
    esac
    ;;
  workflow)
    shift
    bash "$PROJECT_ROOT/scripts/manage.sh" "$@"
    ;;
  cloud)
    case $2 in
      orchestrate) bash "$PROJECT_ROOT/bin/orchestrate.sh" ;;
      integrations) bash "$PROJECT_ROOT/bin/integration_runner.sh" ;;
      *) usage ;;
    esac
    ;;
  ai)
    case $2 in
      ai-tools) bash "$PROJECT_ROOT/bin/ai_tools.sh" ;;
      analyze-ci-log) bash "$PROJECT_ROOT/bin/analyze_ci_log.sh" ;;
      analyze-test-log) bash "$PROJECT_ROOT/bin/analyze_test_log.sh" ;;
      *) usage ;;
    esac
    ;;
  workspace)
    case $2 in
      config) cat "$PROJECT_ROOT/config/settings.conf" 2>/dev/null || echo "No config found." ;;
      list-files) ls -l "$PROJECT_ROOT" ;;
      *) usage ;;
    esac
    ;;
  *)
    usage
    ;;
