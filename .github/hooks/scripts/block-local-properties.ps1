<#
  PreToolUse guard: keeps coding agents away from secrets.properties and local.properties.

  Shared by GitHub Copilot (.github/hooks/block-local-properties.json) and
  Claude Code (.claude/settings.json). Reads the hook input as JSON from stdin.
  Prints a "deny" decision as JSON, or prints nothing so the normal permission
  flow continues. Works with Windows PowerShell 5.1 and PowerShell 7.
#>

$ProtectedFile = '(?i)(^|[^A-Za-z0-9_.-])(secrets|local)\.properties([^A-Za-z0-9_-]|$)'
$TargetKeys = @('file_path', 'filePath', 'path', 'paths', 'notebook_path', 'pattern', 'glob', 'include', 'command', 'cmd', 'script')
$Reason = 'Blocked by project hook: secrets.properties and local.properties may contain the TMDB API key. ' +
          'Agents must never read, edit, search or print them. Ask the user to make this change manually.'

$format = 'copilot'

function Write-Deny([string]$message) {
    if ($script:format -eq 'claude') {
        $result = @{ hookSpecificOutput = @{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $message
        } }
    } else {
        $result = @{ permissionDecision = 'deny'; permissionDecisionReason = $message }
    }
    [Console]::Out.Write(($result | ConvertTo-Json -Depth 5 -Compress))
    exit 0
}

function Get-TrackedSecretFiles([string]$directory) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return @() }
    if (-not $directory) { $directory = (Get-Location).Path }
    $top = & git -C $directory rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $top) { return @() }
    $files = & git -C $top ls-files 2>$null
    return @($files | Where-Object { $_ -match $ProtectedFile })
}

try {
    $data = [Console]::In.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop
} catch {
    [Console]::Error.WriteLine('block-local-properties: could not parse hook input, blocking to be safe.')
    exit 2
}

# Claude Code sends tool_name/tool_input, Copilot sends toolName/toolArgs.
$names = @($data.PSObject.Properties | ForEach-Object { $_.Name })
if ($names -contains 'tool_name') {
    $format = 'claude'
    $tool = [string]$data.tool_name
    $toolArgs = $data.tool_input
} else {
    $tool = [string]$data.toolName
    $toolArgs = $data.toolArgs
    if ($toolArgs -is [string]) {
        try { $toolArgs = $toolArgs | ConvertFrom-Json -ErrorAction Stop } catch { $toolArgs = [pscustomobject]@{ command = $toolArgs } }
    }
}
if ($null -eq $toolArgs) { exit 0 }

# 1. Any path, pattern or command that names a protected file.
foreach ($property in $toolArgs.PSObject.Properties) {
    if ($TargetKeys -notcontains $property.Name) { continue }
    foreach ($value in @($property.Value)) {
        if ($value -is [string] -and $value -match $ProtectedFile) { Write-Deny $Reason }
    }
}

# 2. Content searches over all .properties files would read the secret files too.
if ($tool -match '(?i)grep|search') {
    foreach ($key in @('glob', 'include')) {
        $value = [string]$toolArgs.$key
        if ($value -match '\*' -and $value -match '(?i)properties') {
            Write-Deny ('Blocked by project hook: searching all .properties files would include the secret files. ' +
                        'Search gradle.properties or local.defaults.properties by name instead.')
        }
    }
}

# 3. Shell commands: wildcards over .properties files and Git operations that could leak the key.
if ($tool -match '(?i)^(bash|powershell|pwsh|shell)$') {
    $command = [string]$toolArgs.command
    if ($command -match '(?i)\*\.properties') {
        Write-Deny ('Blocked by project hook: wildcards over *.properties would include the secret files. ' +
                    'Name the file explicitly, e.g. gradle.properties.')
    }
    if ($command -match '(?i)\bgit\b[^;&|]*\badd\b[^;&|]*\s(-f|--force)\b') {
        Write-Deny 'Blocked by project hook: git add --force could stage ignored secret files. Stage files without --force.'
    }
    if ($command -match '(?i)\bgit\b[^;&|]*\b(commit|push)\b') {
        $tracked = Get-TrackedSecretFiles ([string]$data.cwd)
        if ($tracked.Count -gt 0) {
            Write-Deny ('Blocked by project hook: secret files are tracked by Git (' + ($tracked -join ', ') + '). ' +
                        'Ask the user to untrack them with "git rm --cached <file>" and to fix .gitignore before committing or pushing.')
        }
    }
}

exit 0
