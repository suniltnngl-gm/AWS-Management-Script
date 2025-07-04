 2025-07-04 18:05:00.707Z: Host information

2025-07-04 18:05:00.717Z: ----------------

2025-07-04 18:05:00.718Z: OS: Ubuntu 22.04.5 LTS (stable release)

2025-07-04 18:05:00.718Z: Image details: https://github.com/github/codespaces-host-images/blob/main/README.md

2025-07-04 18:05:00.718Z: ----------------


=================================================================================

2025-07-04 18:05:00.718Z: Configuration starting...

2025-07-04 18:05:00.909Z: Cloning...


=================================================================================

2025-07-04 18:05:00.910Z: Creating container...

2025-07-04 18:05:00.954Z: $ devcontainer up --id-label Type=codespaces --workspace-folder /var/lib/docker/codespacemount/workspace/AWS-Management-Script --mount type=bind,source=/.codespaces/agent/mount/cache,target=/vscode --user-data-folder /var/lib/docker/codespacemount/.persistedshare --container-data-folder .vscode-remote/data/Machine --container-system-data-folder /var/vscode-remote --log-level trace --log-format json --update-remote-user-uid-default never --mount-workspace-git-root false --omit-config-remote-env-from-metadata --skip-non-blocking-commands --skip-post-create --expect-existing-container --config "/var/lib/docker/codespacemount/workspace/AWS-Management-Script/.devcontainer/devcontainer.json" --override-config /root/.codespaces/shared/merged_devcontainer.json --default-user-env-probe loginInteractiveShell --container-session-data-folder /workspaces/.codespaces/.persistedshare/devcontainers-cli/cache --secrets-file /root/.codespaces/shared/user-secrets-envs.json

2025-07-04 18:05:01.145Z: @devcontainers/cli 0.76.0. Node.js v18.20.8. linux 6.8.0-1027-azure x64.

2025-07-04 18:05:01.492Z: $ docker start 3c0f10cbc9543771c54b711d01d2a9da8fac518a70376938695eaa6a5ebb297d

2025-07-04 18:05:03.214Z: 3c0f10cbc9543771c54b711d01d2a9da8fac518a70376938695eaa6a5ebb297d


2025-07-04 18:05:03.216Z: Stop: Run: docker start 3c0f10cbc9543771c54b711d01d2a9da8fac518a70376938695eaa6a5ebb297d

2025-07-04 18:05:03.303Z: Shell server terminated (code: 126, signal: null)

2025-07-04 18:05:03.303Z: {"outcome":"error","message":"An error occurred setting up the container.","description":"An error occurred setting up the container.","containerId":"3c0f10cbc9543771c54b711d01d2a9da8fac518a70376938695eaa6a5ebb297d"}

2025-07-04 18:05:03.303Z: unable to find user vscode: no matching entries in passwd file

2025-07-04 18:05:03.306Z: Error: An error occurred setting up the container.

2025-07-04 18:05:03.306Z:     at D6 (/.codespaces/agent/bin/node_modules/@devcontainers/cli/dist/spec-node/devContainersSpecCLI.js:467:1253)

2025-07-04 18:05:03.306Z:     at Ix (/.codespaces/agent/bin/node_modules/@devcontainers/cli/dist/spec-node/devContainersSpecCLI.js:467:997)

2025-07-04 18:05:03.307Z:     at process.processTicksAndRejections (node:internal/process/task_queues:95:5)

2025-07-04 18:05:03.307Z:     at async Y6 (/.codespaces/agent/bin/node_modules/@devcontainers/cli/dist/spec-node/devContainersSpecCLI.js:484:3842)

2025-07-04 18:05:03.308Z:     at async BC (/.codespaces/agent/bin/node_modules/@devcontainers/cli/dist/spec-node/devContainersSpecCLI.js:484:4957)

2025-07-04 18:05:03.308Z:     at async p7 (/.codespaces/agent/bin/node_modules/@devcontainers/cli/dist/spec-node/devContainersSpecCLI.js:665:202)

2025-07-04 18:05:03.309Z:     at async d7 (/.codespaces/agent/bin/node_modules/@devcontainers/cli/dist/spec-node/devContainersSpecCLI.js:664:14804)

2025-07-04 18:05:03.309Z:     at async /.codespaces/agent/bin/node_modules/@devcontainers/cli/dist/spec-node/devContainersSpecCLI.js:484:1188

2025-07-04 18:05:03.314Z: devcontainer process exited with exit code 1


====================================== ERROR ====================================

2025-07-04 18:05:03.322Z: Failed to create container.

=================================================================================

2025-07-04 18:05:03.323Z: Error: An error occurred setting up the container.

2025-07-04 18:05:03.328Z: Error code: 1302 (UnifiedContainersErrorFatalCreatingContainer)


====================================== ERROR ====================================

2025-07-04 18:05:03.347Z: Container creation failed.

=================================================================================

2025-07-04 18:05:27.023Z:


===================================== WARNING ===================================

2025-07-04 18:05:27.025Z: Creating recovery container.

=================================================================================


=================================================================================

2025-07-04 18:06:11.673Z: Creating container...

2025-07-04 18:06:11.720Z: $ devcontainer up --id-label Type=codespaces --workspace-folder /var/lib/docker/codespacemount/workspace/AWS-Management-Script --mount type=bind,source=/.codespaces/agent/mount/cache,target=/vscode --user-data-folder /var/lib/docker/codespacemount/.persistedshare --container-data-folder .vscode-remote/data/Machine --container-system-data-folder /var/vscode-remote --log-level trace --log-format json --update-remote-user-uid-default never --mount-workspace-git-root false --omit-config-remote-env-from-metadata --skip-non-blocking-commands --skip-post-create --config "/var/lib/docker/codespacemount/workspace/AWS-Management-Script/.devcontainer/devcontainer.json" --override-config /root/.codespaces/shared/merged_devcontainer.json --default-user-env-probe loginInteractiveShell --container-session-data-folder /workspaces/.codespaces/.persistedshare/devcontainers-cli/cache --secrets-file /root/.codespaces/shared/user-secrets-envs.json

2025-07-04 18:06:11.946Z: @devcontainers/cli 0.76.0. Node.js v18.20.8. linux 6.8.0-1027-azure x64.

2025-07-04 18:06:12.696Z: $alpine -c echo Container started

2025-07-04 18:06:12.754Z: Unable to find image 'mcr.microsoft.com/devcontainers/base:alpine' locally

2025-07-04 18:06:13.103Z: alpine: Pulling from devcontainers/base

2025-07-04 18:06:13.193Z:

2025-07-04 18:06:13.193Z: [1A[2K

f18232174bc9: Pulling fs layer

[1B

[1A[2K

7c361397357e: Pulling fs layer

[1B

[1A[2K2025-07-04 18:06:13.195Z:

706d566b0a96: Pulling fs layer

[1B

[1A[2K

115d093b6532: Pulling fs layer

[1B

[1A[2K

0995c357df87: Pulling fs layer

[1B

[1A[2K

f465d0ee3e3b: Pulling fs layer

[1B

[1A[2K

2974daf43491: Pulling fs layer

[1B[4A[2K

115d093b6532: Waiting

[4B[3A[2K

0995c357df87: Waiting

[3B[2A[2K

f465d0ee3e3b: Waiting

[2B[1A[2K

2974daf43491: Waiting

[1B2025-07-04 18:06:13.361Z: [5A[2K

706d566b0a96: Downloading     134B/134B

[5B[5A[2K

706d566b0a96: Verifying Checksum

[5B[5A[2K

706d566b0a96: Download complete

[5B2025-07-04 18:06:13.364Z: [7A[2K

f18232174bc9: Downloading  48.35kB/3.642MB

[7B2025-07-04 18:06:13.375Z: [6A2025-07-04 18:06:13.375Z: [2K2025-07-04 18:06:13.380Z:

7c361397357e: Downloading     410B/410B

[6B[6A[2K

7c361397357e: Verifying Checksum

[6B[6A[2K

7c361397357e: Download complete

[6B2025-07-04 18:06:13.406Z: [7A[2K

f18232174bc9: Verifying Checksum

[7B[7A[2K

f18232174bc9: 2025-07-04 18:06:13.406Z: Download complete

[7B2025-07-04 18:06:13.496Z: [4A[2K

115d093b6532: Downloading     223B/223B

[4B2025-07-04 18:06:13.497Z: [4A[2K

115d093b6532: Verifying Checksum

[4B2025-07-04 18:06:13.498Z: [4A[2K

115d093b6532: Download complete

[4B2025-07-04 18:06:13.521Z: [7A[2K

2025-07-04 18:06:13.521Z: f18232174bc9: Extracting  65.54kB/3.642MB

[7B2025-07-04 18:06:13.538Z: [3A[2K

0995c357df87: Downloading     233B/233B

[3B2025-07-04 18:06:13.538Z: [3A[2K

0995c357df87: Verifying Checksum

[3B2025-07-04 18:06:13.538Z: [3A[2K

0995c357df87: Download complete

[3B2025-07-04 18:06:13.565Z: [2A2025-07-04 18:06:13.571Z: [2K

f465d0ee3e3b: Downloading  538.7kB/241.1MB

[2B2025-07-04 18:06:13.664Z: [7A[2K

f18232174bc9: Extracting  1.376MB/3.642MB

[7B2025-07-04 18:06:13.664Z: [1A[2K

2974daf43491: Downloading  456.8kB/44.33MB

2025-07-04 18:06:13.665Z: [1B2025-07-04 18:06:13.666Z: [2A[2K

f465d0ee3e3b: Downloading  9.175MB/241.1MB

[2B2025-07-04 18:06:13.762Z: [7A[2K

f18232174bc9: Extracting  2.032MB/3.642MB

[7B2025-07-04 18:06:13.764Z: [1A[2K

2974daf43491: Downloading  12.37MB/44.33MB

[1B2025-07-04 18:06:13.768Z: [2A[2K

f465d0ee3e3b: Downloading  16.74MB/241.1MB

[2B2025-07-04 18:06:13.861Z: [7A[2K

f18232174bc9: Extracting  2.884MB/3.642MB

[7B2025-07-04 18:06:13.867Z: [2A[2K

f465d0ee3e3b: Downloading  31.34MB/241.1MB

[2B2025-07-04 18:06:13.868Z: [1A[2K

2974daf43491: Downloading  27.05MB/44.33MB

[1B2025-07-04 18:06:13.942Z: [7A[2K

f18232174bc9: 2025-07-04 18:06:13.943Z: Extracting  3.642MB/3.642MB

[7B2025-07-04 18:06:13.945Z: [7A[2K

f18232174bc9: Extracting  3.642MB/3.642MB

[7B2025-07-04 18:06:13.973Z: [1A2025-07-04 18:06:13.974Z: [2K

2974daf43491: Downloading  38.06MB/44.33MB

[1B2025-07-04 18:06:13.980Z: [2A[2K

f465d0ee3e3b: Downloading  41.62MB/241.1MB

[2B2025-07-04 18:06:14.080Z: [1A[2K

2974daf43491: Downloading  44.02MB/44.33MB

[1B2025-07-04 18:06:14.089Z: [1A[2K

2974daf43491: Verifying Checksum

[1B[1A[2K

2974daf43491: Download complete

[1B2025-07-04 18:06:14.098Z: [2A[2K

f465d0ee3e3b: Downloading  47.02MB/241.1MB

[2B2025-07-04 18:06:14.194Z: [2A[2K

f465d0ee3e3b: Downloading  60.54MB/241.1MB

[2B2025-07-04 18:06:14.292Z: [2A[2K

f465d0ee3e3b: Downloading  79.46MB/241.1MB

[2B2025-07-04 18:06:14.394Z: [2A[2K

f465d0ee3e3b: Downloading  94.06MB/241.1MB

[2B2025-07-04 18:06:14.493Z: [2A[2K2025-07-04 18:06:14.497Z:

f465d0ee3e3b: Downloading  109.2MB/241.1MB

[2B2025-07-04 18:06:14.601Z: [2A[2K

f465d0ee3e3b: Downloading    126MB/241.1MB

[2B2025-07-04 18:06:14.699Z: [2A[2K

f465d0ee3e3b: Downloading  141.6MB/241.1MB

[2B2025-07-04 18:06:14.802Z: [2A[2K

f465d0ee3e3b: Downloading  159.5MB/241.1MB

[2B2025-07-04 18:06:14.903Z: [2A2025-07-04 18:06:14.905Z: [2K

f465d0ee3e3b: Downloading  174.1MB/241.1MB

[2B2025-07-04 18:06:15.009Z: [2A[2K

f465d0ee3e3b: Downloading  184.9MB/241.1MB

[2B2025-07-04 18:06:15.105Z: [2A[2K

f465d0ee3e3b: Downloading  196.8MB/241.1MB

[2B2025-07-04 18:06:15.212Z: [2A[2K

f465d0ee3e3b: Downloading    213MB/241.1MB

[2B2025-07-04 18:06:15.314Z: [2A2025-07-04 18:06:15.317Z: [2K

f465d0ee3e3b: Downloading    226MB/241.1MB

[2B2025-07-04 18:06:15.408Z: [2A[2K

f465d0ee3e3b: Verifying Checksum

[2B[2A[2K

f465d0ee3e3b: Download complete

[2B2025-07-04 18:06:16.886Z: [7A2025-07-04 18:06:16.887Z: [2K

f18232174bc9: Pull complete

[7B2025-07-04 18:06:16.892Z: [6A2025-07-04 18:06:16.892Z: [2K

7c361397357e: Extracting     410B/410B

[6B2025-07-04 18:06:16.894Z: [6A[2K

7c361397357e: Extracting     410B/410B

[6B2025-07-04 18:06:18.586Z: [6A[2K

7c361397357e: Pull complete

[6B2025-07-04 18:06:18.591Z: [5A[2K

706d566b0a96: Extracting     134B/134B

[5B2025-07-04 18:06:18.591Z: [5A[2K

706d566b0a96: Extracting     134B/134B

[5B2025-07-04 18:06:18.609Z: [5A[2K

706d566b0a96: Pull complete

[5B2025-07-04 18:06:18.612Z: [4A[2K

115d093b6532: Extracting     223B/223B

[4B[4A[2K

115d093b6532: Extracting     223B/223B

[4B2025-07-04 18:06:18.639Z: [4A[2K

2025-07-04 18:06:18.639Z: 115d093b6532: Pull complete

[4B2025-07-04 18:06:18.644Z: [3A[2K

0995c357df87: Extracting     233B/233B

[3B2025-07-04 18:06:18.645Z: [3A[2K

0995c357df87: Extracting     233B/233B

[3B2025-07-04 18:06:18.666Z: [3A[2K

0995c357df87: Pull complete

[3B2025-07-04 18:06:18.681Z: [2A[2K

f465d0ee3e3b: Extracting  557.1kB/241.1MB

[2B2025-07-04 18:06:18.783Z: [2A2025-07-04 18:06:18.783Z: [2K

f465d0ee3e3b: Extracting  5.014MB/241.1MB

[2B2025-07-04 18:06:18.885Z: [2A[2K

f465d0ee3e3b: Extracting  12.26MB/241.1MB

[2B2025-07-04 18:06:18.993Z: [2A[2K

f465d0ee3e3b: Extracting  18.94MB/241.1MB

[2B2025-07-04 18:06:19.104Z: [2A[2K

f465d0ee3e3b: Extracting   23.4MB/241.1MB

[2B2025-07-04 18:06:19.213Z: [2A[2K

f465d0ee3e3b: Extracting  24.51MB/241.1MB

[2B2025-07-04 18:06:19.346Z: [2A[2K

f465d0ee3e3b: Extracting  25.07MB/241.1MB

[2B2025-07-04 18:06:19.569Z: [2A[2K

f465d0ee3e3b: Extracting  26.18MB/241.1MB

[2B2025-07-04 18:06:19.707Z: [2A2025-07-04 18:06:19.707Z: [2K

f465d0ee3e3b: Extracting  26.74MB/241.1MB

[2B2025-07-04 18:06:19.859Z: [2A[2K

f465d0ee3e3b: Extracting  30.08MB/241.1MB

[2B2025-07-04 18:06:19.990Z: [2A[2K

2025-07-04 18:06:19.990Z: f465d0ee3e3b: Extracting   31.2MB/241.1MB

[2B2025-07-04 18:06:20.096Z: [2A[2K

f465d0ee3e3b: Extracting  35.65MB/241.1MB

[2B2025-07-04 18:06:20.197Z: [2A2025-07-04 18:06:20.198Z: [2K

f465d0ee3e3b: Extracting  39.55MB/241.1MB

[2B2025-07-04 18:06:20.304Z: [2A[2K

f465d0ee3e3b: Extracting  42.89MB/241.1MB

[2B2025-07-04 18:06:20.426Z: [2A[2K

f465d0ee3e3b: Extracting  47.35MB/241.1MB

[2B2025-07-04 18:06:20.529Z: [2A[2K

f465d0ee3e3b: Extracting  51.81MB/241.1MB

[2B2025-07-04 18:06:20.645Z: [2A2025-07-04 18:06:20.646Z: [2K

f465d0ee3e3b: Extracting  54.03MB/241.1MB

[2B2025-07-04 18:06:20.760Z: [2A2025-07-04 18:06:20.761Z: [2K

f465d0ee3e3b: Extracting  56.26MB/241.1MB

[2B2025-07-04 18:06:20.881Z: [2A[2K

f465d0ee3e3b: Extracting  59.05MB/241.1MB

[2B2025-07-04 18:06:20.992Z: [2A2025-07-04 18:06:20.996Z: [2K

f465d0ee3e3b: Extracting  60.16MB/241.1MB

[2B2025-07-04 18:06:21.105Z: [2A2025-07-04 18:06:21.106Z: [2K

f465d0ee3e3b: Extracting  62.39MB/241.1MB

[2B2025-07-04 18:06:21.207Z: [2A[2K

f465d0ee3e3b: Extracting   67.4MB/241.1MB

[2B2025-07-04 18:06:21.311Z: [2A[2K

f465d0ee3e3b: Extracting  74.09MB/241.1MB

[2B2025-07-04 18:06:21.419Z: [2A[2K

f465d0ee3e3b: Extracting  84.12MB/241.1MB

[2B2025-07-04 18:06:21.523Z: [2A[2K2025-07-04 18:06:21.524Z:

f465d0ee3e3b: Extracting   94.7MB/241.1MB

[2B2025-07-04 18:06:21.627Z: [2A[2K

f465d0ee3e3b: Extracting  101.9MB/241.1MB

[2B2025-07-04 18:06:21.729Z: [2A[2K

f465d0ee3e3b: Extracting  108.6MB/241.1MB

[2B2025-07-04 18:06:21.834Z: [2A[2K

f465d0ee3e3b: Extracting  114.8MB/241.1MB

[2B2025-07-04 18:06:21.980Z: [2A2025-07-04 18:06:21.980Z: [2K

f465d0ee3e3b: Extracting  115.9MB/241.1MB

[2B2025-07-04 18:06:22.096Z: [2A2025-07-04 18:06:22.096Z: [2K

f465d0ee3e3b: Extracting  119.8MB/241.1MB

[2B2025-07-04 18:06:22.228Z: [2A[2K

f465d0ee3e3b: Extracting  120.9MB/241.1MB

[2B2025-07-04 18:06:22.342Z: [2A[2K

f465d0ee3e3b: Extracting  121.4MB/241.1MB

[2B2025-07-04 18:06:22.562Z: [2A[2K

f465d0ee3e3b: Extracting    122MB/241.1MB

[2B2025-07-04 18:06:22.711Z: [2A2025-07-04 18:06:22.711Z: [2K

f465d0ee3e3b: 2025-07-04 18:06:22.712Z: Extracting  123.1MB/241.1MB

[2B2025-07-04 18:06:22.845Z: [2A[2K2025-07-04 18:06:22.846Z:

f465d0ee3e3b: Extracting  123.7MB/241.1MB

[2B2025-07-04 18:06:23.005Z: [2A[2K

f465d0ee3e3b: Extracting  125.3MB/241.1MB

[2B2025-07-04 18:06:23.111Z: [2A[2K

f465d0ee3e3b: Extracting  127.6MB/241.1MB

[2B2025-07-04 18:06:23.230Z: [2A[2K

f465d0ee3e3b: Extracting  130.4MB/241.1MB

[2B2025-07-04 18:06:23.365Z: [2A[2K

f465d0ee3e3b: Extracting  133.1MB/241.1MB

[2B2025-07-04 18:06:23.463Z: [2A2025-07-04 18:06:23.463Z: [2K

f465d0ee3e3b: Extracting  135.9MB/241.1MB

[2B2025-07-04 18:06:23.591Z: [2A[2K

f465d0ee3e3b: Extracting  138.1MB/241.1MB

[2B2025-07-04 18:06:23.699Z: [2A[2K

f465d0ee3e3b: Extracting  140.4MB/241.1MB

[2B2025-07-04 18:06:23.810Z: [2A2025-07-04 18:06:23.811Z: [2K

f465d0ee3e3b: Extracting  143.7MB/241.1MB

[2B2025-07-04 18:06:23.923Z: [2A2025-07-04 18:06:23.923Z: [2K

f465d0ee3e3b: Extracting  146.5MB/241.1MB

[2B2025-07-04 18:06:24.058Z: [2A[2K

f465d0ee3e3b: Extracting  149.3MB/241.1MB

[2B2025-07-04 18:06:24.169Z: [2A[2K

f465d0ee3e3b: Extracting  152.1MB/241.1MB

[2B2025-07-04 18:06:24.285Z: [2A[2K

f465d0ee3e3b: Extracting  153.2MB/241.1MB

[2B2025-07-04 18:06:24.416Z: [2A2025-07-04 18:06:24.417Z: [2K

f465d0ee3e3b: Extracting  155.4MB/241.1MB

[2B2025-07-04 18:06:24.526Z: [2A2025-07-04 18:06:24.526Z: [2K

2025-07-04 18:06:24.529Z: f465d0ee3e3b: Extracting  158.8MB/241.1MB

[2B2025-07-04 18:06:24.646Z: [2A2025-07-04 18:06:24.649Z: [2K

f465d0ee3e3b: Extracting  163.8MB/241.1MB

[2B2025-07-04 18:06:24.754Z: [2A2025-07-04 18:06:24.756Z: [2K

f465d0ee3e3b: Extracting    166MB/241.1MB

2025-07-04 18:06:24.756Z: [2B2025-07-04 18:06:24.860Z: [2A2025-07-04 18:06:24.861Z: [2K

f465d0ee3e3b: Extracting  168.8MB/241.1MB

[2B2025-07-04 18:06:24.975Z: [2A[2K

f465d0ee3e3b: Extracting  170.5MB/241.1MB

[2B2025-07-04 18:06:26.436Z: [2A[2K

f465d0ee3e3b: Extracting  172.1MB/241.1MB

[2B2025-07-04 18:06:26.556Z: [2A[2K

f465d0ee3e3b: Extracting  176.6MB/241.1MB

[2B2025-07-04 18:06:26.661Z: [2A[2K

f465d0ee3e3b: Extracting  177.7MB/241.1MB

[2B2025-07-04 18:06:26.767Z: [2A[2K

f465d0ee3e3b: Extracting  179.4MB/241.1MB

[2B2025-07-04 18:06:26.872Z: [2A[2K

2025-07-04 18:06:26.873Z: f465d0ee3e3b: Extracting  182.7MB/241.1MB

[2B2025-07-04 18:06:26.979Z: [2A[2K2025-07-04 18:06:26.979Z:

f465d0ee3e3b: Extracting  187.7MB/241.1MB

[2B2025-07-04 18:06:27.088Z: [2A[2K

2025-07-04 18:06:27.088Z: f465d0ee3e3b: Extracting  191.1MB/241.1MB

[2B2025-07-04 18:06:29.499Z: [2A[2K

f465d0ee3e3b: Extracting  191.6MB/241.1MB

[2B2025-07-04 18:06:29.601Z: [2A[2K

f465d0ee3e3b: Extracting  196.6MB/241.1MB

[2B2025-07-04 18:06:29.708Z: [2A[2K

f465d0ee3e3b: Extracting    200MB/241.1MB

[2B2025-07-04 18:06:29.811Z: [2A[2K

f465d0ee3e3b: Extracting  205.6MB/241.1MB

[2B2025-07-04 18:06:29.916Z: [2A[2K

f465d0ee3e3b: Extracting  210.6MB/241.1MB

[2B2025-07-04 18:06:30.026Z: [2A[2K

f465d0ee3e3b: Extracting  215.6MB/241.1MB

[2B2025-07-04 18:06:30.139Z: [2A[2K

f465d0ee3e3b: Extracting  221.2MB/241.1MB

[2B2025-07-04 18:06:30.252Z: [2A[2K2025-07-04 18:06:30.253Z:

f465d0ee3e3b: Extracting  224.5MB/241.1MB

[2B2025-07-04 18:06:30.355Z: [2A[2K

f465d0ee3e3b: Extracting  229.5MB/241.1MB

[2B2025-07-04 18:06:30.552Z: [2A[2K

f465d0ee3e3b: Extracting  230.6MB/241.1MB

[2B2025-07-04 18:06:30.715Z: [2A[2K

f465d0ee3e3b: Extracting  232.3MB/241.1MB

[2B2025-07-04 18:06:30.844Z: [2A[2K

f465d0ee3e3b: Extracting  233.4MB/241.1MB

[2B2025-07-04 18:06:31.135Z: [2A[2K

f465d0ee3e3b: Extracting  234.5MB/241.1MB

[2B2025-07-04 18:06:31.235Z: [2A[2K

f465d0ee3e3b: Extracting  235.1MB/241.1MB

[2B2025-07-04 18:06:31.416Z: [2A[2K

f465d0ee3e3b: Extracting  236.2MB/241.1MB

[2B2025-07-04 18:06:31.710Z: [2A[2K

f465d0ee3e3b: Extracting  236.7MB/241.1MB

[2B2025-07-04 18:06:31.859Z: [2A[2K

f465d0ee3e3b: Extracting  237.9MB/241.1MB

[2B2025-07-04 18:06:32.192Z: [2A[2K2025-07-04 18:06:32.193Z:

f465d0ee3e3b: Extracting  238.4MB/241.1MB

[2B2025-07-04 18:06:35.190Z: [2A[2K

f465d0ee3e3b: Extracting    239MB/241.1MB

[2B2025-07-04 18:06:35.214Z: [2A[2K

f465d0ee3e3b: Extracting  241.1MB/241.1MB

[2B2025-07-04 18:06:36.556Z: [2A[2K

f465d0ee3e3b: Pull complete

[2B2025-07-04 18:06:36.581Z: [1A2025-07-04 18:06:36.582Z: [2K

2974daf43491: Extracting  458.8kB/44.33MB

[1B2025-07-04 18:06:36.711Z: [1A2025-07-04 18:06:36.711Z: [2K

2974daf43491: Extracting  1.376MB/44.33MB

[1B2025-07-04 18:06:36.953Z: [1A[2K2025-07-04 18:06:36.953Z:

2974daf43491: Extracting  5.046MB/44.33MB

[1B2025-07-04 18:06:37.157Z: [1A[2K

2974daf43491: Extracting  5.505MB/44.33MB

[1B2025-07-04 18:06:37.263Z: [1A2025-07-04 18:06:37.265Z: [2K

2974daf43491: Extracting  7.799MB/44.33MB

[1B2025-07-04 18:06:37.363Z: [1A2025-07-04 18:06:37.364Z: [2K

2974daf43491: Extracting  10.09MB/44.33MB

[1B2025-07-04 18:06:37.562Z: [1A2025-07-04 18:06:37.562Z: [2K

2974daf43491: Extracting  12.39MB/44.33MB

[1B2025-07-04 18:06:37.724Z: [1A[2K

2974daf43491: Extracting  12.85MB/44.33MB

[1B2025-07-04 18:06:37.872Z: [1A2025-07-04 18:06:37.876Z: [2K

2974daf43491: Extracting  15.14MB/44.33MB

[1B2025-07-04 18:06:37.982Z: [1A[2K

2974daf43491: Extracting  18.81MB/44.33MB

[1B2025-07-04 18:06:38.089Z: [1A[2K

2974daf43491: 2025-07-04 18:06:38.089Z: Extracting   23.4MB/44.33MB

[1B2025-07-04 18:06:38.201Z: [1A[2K

2974daf43491: Extracting  24.77MB/44.33MB

[1B2025-07-04 18:06:38.314Z: [1A2025-07-04 18:06:38.314Z: [2K

2974daf43491: Extracting  27.07MB/44.33MB

[1B2025-07-04 18:06:38.419Z: [1A[2K

2974daf43491: Extracting  28.44MB/44.33MB

[1B2025-07-04 18:06:38.828Z: [1A[2K

2974daf43491: Extracting   28.9MB/44.33MB

[1B2025-07-04 18:06:39.021Z: [1A[2K

2974daf43491: Extracting  29.82MB/44.33MB

[1B2025-07-04 18:06:39.194Z: [1A2025-07-04 18:06:39.195Z: [2K

2974daf43491: Extracting  30.28MB/44.33MB

[1B2025-07-04 18:06:39.366Z: [1A[2K

2974daf43491: Extracting   31.2MB/44.33MB

[1B2025-07-04 18:06:39.521Z: [1A2025-07-04 18:06:39.521Z: [2K

2974daf43491: Extracting  31.65MB/44.33MB

[1B2025-07-04 18:06:39.632Z: [1A[2K

2974daf43491: Extracting  32.11MB/44.33MB

[1B2025-07-04 18:06:39.761Z: [1A[2K

2974daf43491: Extracting  33.03MB/44.33MB

[1B2025-07-04 18:06:40.011Z: [1A[2K2025-07-04 18:06:40.011Z:

2974daf43491: Extracting  33.95MB/44.33MB

[1B2025-07-04 18:06:40.122Z: [1A[2K2025-07-04 18:06:40.123Z:

2974daf43491: Extracting  35.78MB/44.33MB

[1B2025-07-04 18:06:40.288Z: [1A2025-07-04 18:06:40.288Z: [2K

2974daf43491: Extracting   36.7MB/44.33MB

[1B2025-07-04 18:06:40.405Z: [1A[2K

2974daf43491: Extracting  37.62MB/44.33MB

[1B2025-07-04 18:06:40.520Z: [1A[2K

2974daf43491: Extracting  39.45MB/44.33MB

[1B2025-07-04 18:06:40.679Z: [1A[2K

2974daf43491: Extracting  40.37MB/44.33MB

[1B2025-07-04 18:06:40.867Z: [1A[2K

2974daf43491: 2025-07-04 18:06:40.867Z: Extracting  41.29MB/44.33MB

[1B2025-07-04 18:06:40.968Z: [1A[2K2025-07-04 18:06:40.970Z:

2974daf43491: Extracting  41.75MB/44.33MB

[1B2025-07-04 18:06:41.128Z: [1A2025-07-04 18:06:41.128Z: [2K

2974daf43491: Extracting  42.21MB/44.33MB

[1B2025-07-04 18:06:41.151Z: [1A2025-07-04 18:06:41.152Z: [2K

2974daf43491: Extracting  44.33MB/44.33MB

[1B2025-07-04 18:06:42.533Z: [1A[2K

2974daf43491: Pull complete

[1B2025-07-04 18:06:42.566Z: Digest: sha256:f18f0de5a4d3fc76323133e0fa696258ddcfc10bef2b47adb5fdda3cf4704623

2025-07-04 18:06:42.576Z: Status: Downloaded newer image for mcr.microsoft.com/devcontainers/base:alpine

2025-07-04 18:06:43.933Z: Container started

2025-07-04 18:06:45.370Z: Outcome: success User: vscode WorkspaceFolder: /workspaces/AWS-Management-Script

2025-07-04 18:06:45.381Z: devcontainer process exited with exit code 0


=================================================================================

2025-07-04 18:06:46.572Z: Running blocking commands...

2025-07-04 18:06:46.641Z: $ devcontainer up --id-label Type=codespaces --workspace-folder /var/lib/docker/codespacemount/workspace/AWS-Management-Script --mount type=bind,source=/.codespaces/agent/mount/cache,target=/vscode --user-data-folder /var/lib/docker/codespacemount/.persistedshare --container-data-folder .vscode-remote/data/Machine --container-system-data-folder /var/vscode-remote --log-level trace --log-format json --update-remote-user-uid-default never --mount-workspace-git-root false --omit-config-remote-env-from-metadata --skip-non-blocking-commands --expect-existing-container --config "/var/lib/docker/codespacemount/workspace/AWS-Management-Script/.devcontainer/devcontainer.json" --override-config /root/.codespaces/shared/merged_devcontainer.json --default-user-env-probe loginInteractiveShell --container-session-data-folder /workspaces/.codespaces/.persistedshare/devcontainers-cli/cache --secrets-file /root/.codespaces/shared/user-secrets-envs.json

2025-07-04 18:06:46.963Z: @devcontainers/cli 0.76.0. Node.js v18.20.8. linux 6.8.0-1027-azure x64.

2025-07-04 18:06:47.358Z: Outcome: success User: vscode WorkspaceFolder: /workspaces/AWS-Management-Script

2025-07-04 18:06:47.368Z: devcontainer process exited with exit code 0


=================================================================================

2025-07-04 18:06:47.392Z: Configuring codespace...


=================================================================================

2025-07-04 18:06:47.392Z: Finished configuring codespace. 