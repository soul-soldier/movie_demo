#!/usr/bin/env bash
# PreToolUse guard: keeps coding agents away from secrets.properties and local.properties.
#
# Shared by GitHub Copilot (.github/hooks/block-local-properties.json) and Claude Code.
# Reads the hook input as JSON from stdin. Prints a "deny" decision as JSON, or prints
# nothing so the normal permission flow continues. Uses jq when available; without jq
# it falls back to a stricter check on the raw input.

PROTECTED='(^|[^[:alnum:]_.-])(secrets|local)\.properties([^[:alnum:]_-]|$)'
REASON='Blocked by project hook: secrets.properties and local.properties may contain the TMDB API key. Agents must never read, edit, search or print them. Ask the user to make this change manually.'

input=$(cat)
format=copilot
grep -q '"tool_name"' <<<"$input" && format=claude

deny() {
  if [ "$format" = claude ]; then
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}' "$1"
  else
    printf '{"permissionDecision":"deny","permissionDecisionReason":"%s"}' "$1"
  fi
  exit 0
}

tracked_secret_files() {
  command -v git >/dev/null 2>&1 || return 0
  local top
  top=$(git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null) || return 0
  git -C "$top" ls-files 2>/dev/null | grep -Ei "$PROTECTED" | tr '\n' ' '
}

if command -v jq >/dev/null 2>&1; then
  if ! jq -e 'type == "object"' <<<"$input" >/dev/null 2>&1; then
    echo 'block-local-properties: could not parse hook input, blocking to be safe.' >&2
    exit 2
  fi
  if [ "$format" = claude ]; then
    tool=$(jq -r '.tool_name // ""' <<<"$input")
    args=$(jq -c '.tool_input // {}' <<<"$input")
  else
    tool=$(jq -r '.toolName // ""' <<<"$input")
    args=$(jq -c '.toolArgs // {} | if type == "string" then (fromjson? // {command: .}) else . end' <<<"$input")
  fi
  cwd=$(jq -r '.cwd // "."' <<<"$input")
  targets=$(jq -r '
    to_entries[]
    | select(.key | IN("file_path", "filePath", "path", "paths", "notebook_path", "pattern", "glob", "include", "command", "cmd", "script"))
    | .value | if type == "array" then .[] else . end | strings' <<<"$args")
  command_text=$(jq -r '.command // "" | strings' <<<"$args")
  search_globs=$(jq -r '[.glob, .include] | map(strings) | join(" ")' <<<"$args")
else
  # Without jq: check the whole input. This can also block edits whose new content
  # merely mentions a protected file name. Install jq for precise checks.
  tool=shell
  cwd=.
  targets=$input
  command_text=$input
  search_globs=''
fi

# 1. Any path, pattern or command that names a protected file.
if grep -Eiq "$PROTECTED" <<<"$targets"; then
  deny "$REASON"
fi

# 2. Content searches over all .properties files would read the secret files too.
if grep -Eiq 'grep|search' <<<"$tool" && grep -q '\*' <<<"$search_globs" && grep -qi 'properties' <<<"$search_globs"; then
  deny 'Blocked by project hook: searching all .properties files would include the secret files. Search gradle.properties or local.defaults.properties by name instead.'
fi

# 3. Shell commands: wildcards over .properties files and Git operations that could leak the key.
if grep -Eiq '^(bash|powershell|pwsh|shell)$' <<<"$tool"; then
  if grep -Eiq '\*\.properties' <<<"$command_text"; then
    deny 'Blocked by project hook: wildcards over *.properties would include the secret files. Name the file explicitly, e.g. gradle.properties.'
  fi
  if grep -Eiq '(^|[^[:alnum:]])git[^;&|]*[[:space:]]add[[:space:]][^;&|]*(-f|--force)([[:space:]]|$)' <<<"$command_text"; then
    deny 'Blocked by project hook: git add --force could stage ignored secret files. Stage files without --force.'
  fi
  if grep -Eiq '(^|[^[:alnum:]])git[^;&|]*[[:space:]](commit|push)([[:space:]]|$)' <<<"$command_text"; then
    tracked=$(tracked_secret_files "$cwd")
    if [ -n "$tracked" ]; then
      deny "Blocked by project hook: secret files are tracked by Git (${tracked% }). Ask the user to untrack them with git rm --cached and to fix .gitignore before committing or pushing."
    fi
  fi
fi

exit 0
