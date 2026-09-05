---
name: ai-ecosystem
description: "Use when configuring, modifying, or auditing AI agents, tools, MCP servers, skills, or global rules across the AI Trio (Pi, OpenCode, Antigravity) to ensure complete parity."
---

# Skill: AI Ecosystem Parity & Tooling (`ai-ecosystem`)

## Purpose
Maintains 100% parity across the three primary AI agents in this environment: **Pi (`pi`)**, **OpenCode (`opencode`)**, and **Antigravity (`agy`)**. Whenever a new tool, MCP, skill, or rule is introduced, this skill enforces the single-source-of-truth architecture.

## The AI Trio Architecture
- **Pi:** CLI & TUI agent using TypeScript extensions (`~/.pi/agent/`).
- **OpenCode:** TUI agent using multi-agent modes (`~/.config/opencode/`).
- **Antigravity:** Agentic CLI & subagent orchestrator (`~/.gemini/`).

## Operational Runbooks

### 1. Adding or Modifying Global Rules
- **Rule:** Global rules live ONLY in `/home/yordycg/.local/share/chezmoi/dot_pi/agent/AGENTS.md`.
- **Sync:**
  - OpenCode automatically compiles from `dot_config/opencode/AGENTS.md.tmpl` via Chezmoi.
  - Antigravity reads `~/.gemini/config/rules/global.md` (symlinked).
- Never duplicate rule files manually across directories.

### 2. Creating or Updating Skills
- **Location:** All skills live in `~/.agents/skills/<skill-name>/SKILL.md` (tracked in Chezmoi under `dot_agents/skills/`).
- **Sync:**
  - OpenCode and Pi read `~/.agents/skills/` natively.
  - Antigravity reads `~/.gemini/config/skills/` (symlinked to `~/.agents/skills/`).
- Always include YAML frontmatter (`name:`, `description:`).

### 3. Adding an MCP Server (e.g. `foo-mcp`)
When registering a new MCP server, configure all 3 tools:
1. **OpenCode:** Add to `~/.config/opencode/opencode.jsonc` under `"mcp"`:
   ```json
   "foo": { "type": "local", "command": ["foo-mcp"], "enabled": true }
   ```
2. **Antigravity:** Register via CLI:
   ```bash
   agy mcp add foo foo-mcp [args...]
   ```
3. **Pi:** Register in `~/.pi/agent/settings.json` under `"packages"` (if npm/extension) or via extension wrapper in `~/.pi/agent/extensions/`.

### 4. Plan / Build Workflow
- **OpenCode:** Starts in Plan mode (`default_agent: "plan"`). Switch with `Tab` or `/build`.
- **Pi:** Toggle with `/plan` command, `Ctrl+Alt+P`, or start with `pi --plan`. Read-only tools only. Switch to execution upon user approval.
- **Antigravity:** Use `/plan` or start with `agy --mode plan`.
