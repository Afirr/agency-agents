<#
.SYNOPSIS
  Installs The Agency agents into Claude Code on Windows (no bash/WSL needed).

.DESCRIPTION
  Windows counterpart of `./scripts/install.sh --tool claude-code`.
  Copies every agent file (a .md whose first line is the `---` frontmatter
  fence) from the division folders into Claude Code's agents directory.

  Destination, in priority order:
    -Path <dir>          explicit folder
    -Project             .\.claude\agents in the current directory
    $env:CLAUDE_CONFIG_DIR\agents
    $HOME\.claude\agents (default)

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -Division engineering,design

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -Project
#>
[CmdletBinding()]
param(
  [string[]]$Division,
  [string]$Path,
  [switch]$Project,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot

# Division list comes from divisions.json (same source of truth as install.sh),
# plus strategy/ which install.sh also scans.
$json = Get-Content -Raw -Encoding UTF8 (Join-Path $RepoRoot 'divisions.json') | ConvertFrom-Json
$allDivisions = @($json.divisions.PSObject.Properties.Name) + 'strategy'

if ($Division) {
  $Division = @($Division | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
  $unknown = @($Division | Where-Object { $allDivisions -notcontains $_ })
  if ($unknown.Count -gt 0) {
    throw "Unknown division(s): $($unknown -join ', '). Valid: $($allDivisions -join ', ')"
  }
  $dirs = $Division
} else {
  $dirs = $allDivisions
}

if ($Path) {
  $dest = $Path
} elseif ($Project) {
  $dest = Join-Path (Get-Location) '.claude\agents'
} elseif ($env:CLAUDE_CONFIG_DIR) {
  $dest = Join-Path $env:CLAUDE_CONFIG_DIR 'agents'
} else {
  $dest = Join-Path $HOME '.claude\agents'
}

Write-Host 'The Agency -- Installing agents for Claude Code'
Write-Host "  Repo: $RepoRoot"
Write-Host "  Dest: $dest"

if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $dest | Out-Null }

$count = 0
foreach ($d in $dirs) {
  $src = Join-Path $RepoRoot $d
  if (-not (Test-Path $src)) { continue }
  Get-ChildItem -Path $src -Recurse -File -Filter '*.md' | ForEach-Object {
    # Agent files start with a YAML frontmatter fence; strip a UTF-8 BOM if present.
    $first = (Get-Content -LiteralPath $_.FullName -TotalCount 1 -Encoding UTF8)
    if ($first) { $first = $first.TrimStart([char]0xFEFF).TrimEnd() }
    if ($first -ne '---') { return }
    if ($DryRun) {
      Write-Host "  would copy $($_.Name)"
    } else {
      Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
    }
    $script:count++
  }
}

if ($DryRun) {
  Write-Host "[DRY RUN] $count agents would be installed -> $dest"
} else {
  Write-Host "[OK]  Claude Code: $count agents -> $dest" -ForegroundColor Green
  Write-Host '  Restart Claude Code (or open a new session), then run /agents to see them.'
}
