<#
.SYNOPSIS
    Applies a unified diff file to the repository.
.DESCRIPTION
    This script provides a standardized way to apply AI-assisted edits in a PowerShell environment.
.PARAMETER PatchFile
    The path to the .diff file to apply.
.EXAMPLE
    .\tools\apply_patch.ps1 -PatchFile my_feature.diff
#>
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$PatchFile
)

if (-not (Test-Path -Path $PatchFile -PathType Leaf)) {
    Write-Error "Error: Patch file not found at '$PatchFile'"
    exit 1
}

Write-Host "--- Applying patch: $PatchFile ---"
git apply --verbose $PatchFile
Write-Host "--- Patch applied successfully. Please review the changes. ---"