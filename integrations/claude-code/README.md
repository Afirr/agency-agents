# Claude Code Integration

The Agency was built for Claude Code. No conversion needed — agents work
natively with the existing `.md` + YAML frontmatter format.

## Install

```bash
# Copy all agents to your Claude Code agents directory
./scripts/install.sh --tool claude-code

# Or manually copy a category
cp engineering/*.md ~/.claude/agents/
```

### Windows (PowerShell)

`install.sh` is a bash script and does not run in PowerShell or CMD. Use the
PowerShell installer instead (no WSL or Git Bash needed):

```powershell
git clone https://github.com/msitarzewski/agency-agents
cd agency-agents

# All agents -> %USERPROFILE%\.claude\agents
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1

# Only some divisions
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -Division engineering,design

# Into the current project's .claude\agents instead of your user folder
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1 -Project
```

Restart Claude Code (or open a new session) afterwards and run `/agents` to
confirm they are loaded.

## Activate an Agent

In any Claude Code session, reference an agent by name:

```
Activate Frontend Developer and help me build a React component.
```

```
Use the Reality Checker agent to verify this feature is production-ready.
```

## Agent Directory

Agents are organized into divisions. See the [main README](../../README.md) for
the full Agency roster.
