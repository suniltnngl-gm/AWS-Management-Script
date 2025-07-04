# Makefile for AWS-Management-Script
# Provides a simple interface to the scripts in the bin/ directory.

# --- Configuration ---
# These can be overridden from the command line.
# Example: make deploy S3_BUCKET_NAME=my-production-bucket
S3_BUCKET_NAME ?= your-aws-scripts-bucket
AWS_REGION     ?= us-east-1
SHELL          := /bin/bash

.PHONY: all test analyze build deploy run clean help

help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

analyze: ## Run static analysis and linting on all scripts
	@echo "--- Running project analysis ---"
	@./bin/test_all.sh --lint-only

test: analyze ## Run the full test suite
	@echo "--- Running all tests ---"
	@./bin/test_all.sh

build: test ## Build the project artifact
	@echo "--- Building project artifact ---"
	@./bin/orchestrate.sh build

deploy: build ## Deploy the latest build to AWS S3
	@echo "--- Deploying to AWS S3 ---"
	@./bin/orchestrate.sh deploy --bucket $(S3_BUCKET_NAME) --region $(AWS_REGION)

clean: ## Remove build artifacts and temporary files
	@echo "--- Cleaning up artifacts and logs ---"
	@rm -rf artifacts/ *.log