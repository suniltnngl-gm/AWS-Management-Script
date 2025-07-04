# AI-Assisted Editing Guidelines

This document outlines the standard process for using AI code assistants (like Gemini Code Assist, GitHub Copilot, etc.) to edit this repository. Following this plan and checklist ensures that all AI-assisted contributions are high-quality, intentional, and align with project standards.

## The Three-Phase Process: Plan, Apply, and Review

Every AI-assisted edit must follow a three-phase process:

1.  **Plan:** Define the goal and scope *before* prompting the AI.
2.  **Apply:** Use standard tooling to apply the AI-generated patch.
3.  **Review (Checklist):** Critically review the applied changes *before* committing.

---

### Phase 1: The Plan

Before you ask an AI assistant to write or modify code, you must have a clear plan. This helps you write effective prompts and evaluate the results.

1.  **Define the Objective:** State clearly what you want to achieve.
    *   *Bad Example:* "make logging better"
    *   *Good Example:* "Refactor the `lib/log_utils.sh` library to support structured JSON logging for easier parsing and analysis."

2.  **Identify the Scope:** List the specific files and functions that will be affected.
    *   *Example:* "This will primarily affect `lib/log_utils.sh` and any scripts that call its logging functions, like `bin/orchestrate.sh`."

3.  **Formulate the Prompt:** Write a clear, concise prompt for the AI. Include the objective and scope.
    *   *Example Prompt:* "I have a shell script project with a logging library in `lib/log_utils.sh`. I want to improve it to support structured JSON logging. The new function should take a log level and a message, and output a JSON object with a timestamp, level, message, and script name. Update the existing analysis scripts to handle this new format."

4.  **Generate the Patch:** Request the AI assistant to provide the final changes as a unified diff file (e.g., `feature-x.diff`).

---

### Phase 2: Applying the Changes

Once you have a `.diff` file from the AI assistant, use the provided scripts to apply it. This ensures a consistent application method across all environments.

-   **For Bash (Linux, macOS, CloudShell):**
    ```sh
    ./tools/apply_patch.sh /path/to/your/feature.diff
    ```
-   **For PowerShell (Windows):**
    ```powershell
    ./tools/apply_patch.ps1 -PatchFile C:\path\to\your\feature.diff
    ```

---

### Phase 3: The Review Checklist

**Never trust AI-generated code blindly.** You, the developer, are ultimately responsible for the code you commit. Use this checklist to review every AI suggestion before accepting it.

-   **[ ] Correctness:** Does the code function as intended? Does it solve the original problem without introducing new bugs?
-   **[ ] Readability & Style:** Does the code adhere to the project's existing style? Is it clear, well-commented, and maintainable?
-   **[ ] Simplicity:** Is the solution overly complex? Did the AI add unnecessary dependencies or abstractions? Can it be simplified?
-   **[ ] Security:** Does the code introduce any security vulnerabilities? (e.g., command injection from un-sanitized variables, hardcoded secrets, insecure temporary files).
-   **[ ] Idempotency:** Is the change safe to run multiple times if it's part of a deployment or management script?
-   **[ ] Testing:** If the change affects core logic, have you run existing tests? Do new tests need to be written?
-   **[ ] Documentation:** Have you updated relevant documentation (e.g., READMEs, inline comments) to reflect the changes?
-   **[ ] Scope Adherence:** Did the AI only change the files and functions identified in the plan? If it suggested wider changes, are they justified and understood?

---

### Commit Message Convention

When committing AI-assisted changes, it is helpful to note it in the commit message for transparency.

**Format:**
```
<type>(<scope>): <subject> (AI-assisted)

[optional body]
```

**Example:**
```
feat(logging): Add structured JSON logging (AI-assisted)

The `lib/log_utils.sh` library was refactored to output logs in
JSON format. This enables easier machine parsing and integration
with log analysis tools. The `bin/analyze_ci_log.sh` script was
updated to use `jq` to parse these new logs.
```