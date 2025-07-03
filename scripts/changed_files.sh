#!/bin/bash

# @file changed_files.sh
# @brief List changed files in the repo for targeted AI/code review and automation
# @description Outputs only files changed since last commit or in working tree. Use this to limit AI/code review to only relevant files, reducing token/credit usage. Integrate with manage.sh for efficient workflows.
#
# Usage: ./changed_files.sh [--since <commit>] [--pattern <glob>]
# Example: ./changed_files.sh --since main --pattern '*.sh'
#
# AI Optimization: This script helps both human users and AI assistants focus on only the files that matter, minimizing unnecessary processing and cost.

SINCE="HEAD"
PATTERN="*"

while [[ $# -gt 0 ]]; do
  case $1 in
    --since)
      SINCE="$2"; shift 2;;
    --pattern)
      PATTERN="$2"; shift 2;;
    *) shift;;
  esac
done

git diff --name-only "$SINCE" -- "$PATTERN"
