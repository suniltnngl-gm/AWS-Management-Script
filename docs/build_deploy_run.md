# Build, Deploy, and Run Process

This document outlines the process for testing, building, deploying, and running the scripts in the `AWS-Management-Script` repository. This process is designed to be automated via a CI/CD pipeline (e.g., GitHub Actions, Jenkins, AWS CodePipeline).

This workflow has been refactored for simplicity and efficiency using a central `Makefile`.

## Recommended Environment: AWS CloudShell

It is highly recommended to run all commands from **AWS CloudShell**. CloudShell comes pre-installed with all the necessary tools (`make`, `git`, `aws-cli`, `shellcheck`), ensuring a consistent and secure execution environment.

## Project Structure

-   `Makefile`: The single entry point for all build, test, and deploy tasks.
-   `/scripts`: Contains the core AWS management shell scripts.
-   `/run`: Contains a helper script for executing tasks.
-   `/docs`: Contains project documentation.
-   `/artifacts`: (Git-ignored) Stores temporary build packages.

All primary CI/CD operations are defined as targets in the `Makefile`. You can see a list of all available commands and their descriptions by running:
```sh
make help
```

### 1. Test (`make test`)

This is the first stage of the pipeline. It ensures code quality and correctness by running static analysis with `shellcheck`. It can be extended to run other tests.

**To run in CloudShell:**
```sh
make test
```

## 2. Build (`build/build.sh`)

If tests pass, the build stage creates a distributable package.

-   **Pre-build Check**: Runs the `test_runner.sh` script to ensure no broken code is packaged.
-   **Packaging**: Creates a versioned tarball (`.tar.gz`) of the repository contents.
-   **Artifact Storage**: The resulting artifact is placed in the `/artifacts` directory.

**To run locally:**
```sh
./build/build.sh
```

## 3. Deploy (`deploy/deploy.sh`)

This stage takes the build artifact and deploys it to a location where it can be used, such as an S3 bucket.

**Configuration:**
You **must** edit `deploy/deploy.sh` and set the `S3_BUCKET_NAME` variable to a bucket you control.

**To run locally:**
```sh
./deploy/deploy.sh
```

## 4. Run (`run/run.sh`)

This script provides a standardized way to execute the management scripts from a local clone or a CI/CD environment.

**To run a script locally:**
```sh
./run/run.sh path/to/your/script.sh --with --args
```