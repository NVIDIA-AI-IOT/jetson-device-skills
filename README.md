# jetson-device-skills

## Description

`jetson-device-skills` is a catalog of [Agent Skills](https://agentskills.io/) for working with a live NVIDIA Jetson device after it has booted. The skills are intended to be present on the Jetson and provide agent-readable instructions plus small helper scripts for diagnostics, memory auditing, runtime selection, model serving, benchmarking, packaging guidance, and related Jetson device workflows.

This repository is device-side. Skills here run on the Jetson, inspect the Jetson, or provide commands that an agent should execute on the Jetson. BSP customization before flashing belongs in the sibling [`jetson-bsp-skills`](https://github.com/NVIDIA-AI-IOT/jetson-bsp-skills) repository.

This project is currently not accepting contributions.

## Included Skills

- `jetson-diagnostic` captures a read-only device health snapshot, including Jetson identity, memory, GPU, thermal, power, storage, services, and top processes.
- `jetson-memory-audit` measures DRAM/NvMap usage and verifies before/after memory reclamation with live audit data.
- `jetson-headless-mode` helps turn a Jetson into a headless edge node by disabling the desktop and safe background services.
- `jetson-inference-mem-tune` recommends serving runtimes and memory flags for vLLM, SGLang, llama.cpp, and TensorRT Edge-LLM.
- `jetson-llm-serve` provides Jetson-appropriate vLLM and SGLang serving recipes.
- `jetson-llm-benchmark` emits structured benchmark metrics for vLLM, llama.cpp, and `Ollama` paths.
- `jetson-package` guides Jetson-specific package, wheel, and container choices.
- `jetson-speculative-decoding` adds Jetson-specific EAGLE-3 or draft-model speculative decoding guidance for vLLM.

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
    └── jetson-speculative-decoding/
```

## License

This code is dual-licensed with documentation under the CC-BY-4.0 AND source code under Apache-2.0 license terms. See [LICENSE](LICENSE).
