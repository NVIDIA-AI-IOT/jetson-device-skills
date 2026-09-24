# NVIDIA Jetson Device Skills

NVIDIA Jetson Device Skills is a catalog of agent skills for working with a live NVIDIA Jetson device after it has booted. You can also discover these skills through the [NVIDIA Agent Skills catalog](https://github.com/NVIDIA/skills), alongside skills for other NVIDIA products.

The skills provide agent-readable instructions and helper scripts for diagnostics, memory optimization, package selection, LLM serving, and inference and video benchmarking. Use them with Claude Code, Codex, Cursor, or other compatible coding agents to carry out workflows grounded in your live device’s configuration.

For host-side BSP customization and flashing workflows, see [Jetson BSP Skills](https://github.com/NVIDIA-AI-IOT/jetson-bsp-skills).

## Start Here

New to AI-assisted development on Jetson?

- **[Hands-on walkthrough: AI-assisted development on Jetson](https://www.jetson-ai-lab.com/tutorials/ai-assisted-development-on-jetson/)** — Follow a guided workflow from device preparation to a live VLM demo using a coding agent.
- **[Jetson Agent Skills guide](https://www.jetson-ai-lab.com/tutorials/jetson-agent-skills/)** — Learn how skills work, choose between Device and BSP Skills, and explore installation options.
- **[NVIDIA Agent Skills catalog](https://github.com/NVIDIA/skills)** — Discover Jetson skills alongside skills for other NVIDIA products.

This project is currently not accepting contributions.

## Installation

Clone the repository on the Jetson device:

```bash
git clone https://github.com/NVIDIA-AI-IOT/jetson-device-skills.git
cd jetson-device-skills
```

Install the skills into the agent skill directories on the Jetson:

```bash
./install.sh
```

By default, `install.sh` links the skills into the user-level skill roots for Claude Code, Codex, and Cursor:

- `~/.claude/skills`
- `~/.codex/skills`
- `~/.agents/skills`
- `~/.cursor/skills`

You can select specific targets or copy files instead of creating symbolic links:

```bash
./install.sh --targets claude,cursor
./install.sh --targets cursor-project --project /path/to/project
./install.sh --copy
./install.sh --force
```

For NemoClaw/OpenClaw sandboxes:

```bash
./install.sh --targets nemoclaw --nemoclaw-sandbox jetson-skills
```

Restart the agent session after installation so the new skill entries are picked up. If your agent expects a different skill directory, copy or sync the `skills/` directory into that location. Keep each skill as a complete directory containing its `SKILL.md`, `scripts/`, and `references/` content.

## Included Skills

| Skill | What it helps you do |
|---|---|
| [jetson-diagnostic](skills/jetson-diagnostic/SKILL.md) | Inspect device identity, memory, GPU activity, thermals, power, storage, and services. |
| [jetson-memory-audit](skills/jetson-memory-audit/SKILL.md) | Measure memory usage and verify the effect of memory reclamation. |
| [jetson-headless-mode](skills/jetson-headless-mode/SKILL.md) | Configure a headless Jetson by managing desktop and background services. |
| [jetson-inference-mem-tune](skills/jetson-inference-mem-tune/SKILL.md) | Choose inference runtimes and memory settings for the device. |
| [jetson-llm-serve](skills/jetson-llm-serve/SKILL.md) | Configure Jetson-appropriate LLM serving workflows. |
| [jetson-llm-benchmark](skills/jetson-llm-benchmark/SKILL.md) | Measure LLM inference performance with structured benchmark results. |
| [jetson-package](skills/jetson-package/SKILL.md) | Select Jetson-compatible packages, wheels, and containers. |
| [jetson-speculative-decoding](skills/jetson-speculative-decoding/SKILL.md) | Explore Jetson-specific speculative decoding configurations. |
| [jetson-video-setup](skills/jetson-video-setup/SKILL.md) | Install and verify native Video Codec SDK and PyNvVideoCodec components. |
| [jetson-video-capability](skills/jetson-video-capability/SKILL.md) | Check live encode/decode capabilities against documented device support. |
| [jetson-video-recipe](skills/jetson-video-recipe/SKILL.md) | Translate video codec requirements into validated configuration plans. |
| [jetson-video-benchmark](skills/jetson-video-benchmark/SKILL.md) | Measure encode and decode performance on the device. |
| [jetson-video-pipeline](skills/jetson-video-pipeline/SKILL.md) | Execute and verify video codec pipeline stages. |

## Usage

Each skill lives under `skills/<skill-name>/` and starts with a `SKILL.md` file. After `install.sh` links or copies the skills into the agent's skill directory, agent runtimes such as Cursor, Claude Code, Codex, or NemoClaw/OpenClaw can discover the skills from their frontmatter descriptions and follow the instructions in the selected skill.

Some skills include helper scripts under `scripts/`, but users normally do not need to call those scripts directly. The agent should invoke the relevant helper when a skill asks for live Jetson data, then use the returned output as the source of truth.

## Repository Layout

```text
jetson-device-skills/
├── README.md
├── LICENSE
├── install.sh
├── agents/
└── skills/
    ├── jetson-diagnostic/
    ├── jetson-headless-mode/
    ├── jetson-inference-mem-tune/
    ├── jetson-llm-benchmark/
    ├── jetson-llm-serve/
    ├── jetson-memory-audit/
    ├── jetson-package/
    ├── jetson-speculative-decoding/
    ├── jetson-video-benchmark/
    ├── jetson-video-capability/
    ├── jetson-video-pipeline/
    ├── jetson-video-recipe/
    └── jetson-video-setup/
```

## Related Resources

- [Jetson AI Lab](https://www.jetson-ai-lab.com/) — Models, tutorials, and applications for generative AI on Jetson.
- [NVIDIA Agent Skills](https://github.com/NVIDIA/skills) — The central NVIDIA skills catalog.
- [Jetson BSP Skills](https://github.com/NVIDIA-AI-IOT/jetson-bsp-skills) — Skills for host-side BSP customization and flashing workflows.
- [Report an issue](https://github.com/NVIDIA-AI-IOT/jetson-device-skills/issues) — Report a bug or documentation problem. For security issues, follow [SECURITY.md](SECURITY.md).

## License

This code is dual-licensed with documentation under the CC-BY-4.0 AND source code under Apache-2.0 license terms. See [LICENSE](LICENSE).
