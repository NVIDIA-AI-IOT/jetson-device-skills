# `agents/` — sub-agents for Jetson workflows

This directory holds **Claude Code sub-agents**: long-running specialist workers that own their own system prompt and a curated tool set, and that orchestrate one or more skills from `skills/`.

> **Skills are portable. Agents are Claude Code-specific.** A skill in `skills/` works in Cursor, Copilot, NemoClaw, Codex, and Claude Code without modification. A sub-agent in `agents/` only loads when the runtime understands the Claude Code sub-agent format. Other agents can still call the underlying skills directly — they just won't get the orchestration layer.

If you only have time to author one of the two, author a **skill**. Add an agent only when the orchestration is non-trivial enough that smaller models would not reliably get the call sequence right on their own.

## On-disk shape

```text
agents/
└── jetson-<role>.md          # one file per sub-agent
```

Each file is a markdown document with a YAML frontmatter block:

```markdown
---
name: jetson-perf-investigator
description: Diagnose Jetson performance issues end to end.
tools: Bash, Read, Grep, Glob
---

# System prompt body...
```

| Frontmatter field | Purpose |
|---|---|
| `name` | Sub-agent identifier. Must match the filename. Use `jetson-<role>` (kebab-case). |
| `description` | One-line trigger description. Used by the parent agent to decide when to delegate. |
| `tools` | Comma-separated list of tools the sub-agent is allowed to invoke. Keep this minimal. |

## Available sub-agents

| Agent | Purpose |
|---|---|
| [`jetson-perf-investigator.md`](jetson-perf-investigator.md) | End-to-end Jetson performance investigation; runs diagnostic + memory audit + targeted recommendations and reports back. |

## Authoring guidelines

- Keep the system prompt **short** (under ~80 lines). Smaller models follow shorter prompts better; cloud models are fine either way.
- Always **delegate** to skills under `skills/` rather than re-implementing logic in the agent body. The agent is glue.
- List every tool the agent needs in the `tools` field. Anything not listed cannot be used.
- Output structured handoffs (JSON or numbered findings) so the parent agent can act on them.
- Default to read-only behavior; only call mutating helpers (`apply.sh --apply`, etc.) after an explicit confirmation step.

## Other agent runtimes

- **Cursor, GitHub Copilot, Codex, NemoClaw**: agent integration paths are tracked in the root [README.md install table](../README.md#install). Where the runtime supports loading `SKILL.md` files directly, the skill bodies are intentionally written so the calling agent can drive them step by step. There is no corresponding sub-agent file format outside Claude Code today.
- **Claude Code**: copy or symlink `agents/` into `~/.claude/agents/` (or your project's `.claude/agents/`). See the root [README.md](../README.md) for the per-agent install snippet.
