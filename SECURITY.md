# Security Policy

## Reporting a Vulnerability

NVIDIA takes the security of its products and services seriously, including all source code repositories under the [NVIDIA-AI-IOT](https://github.com/NVIDIA-AI-IOT) organization.

If you believe you have found a security vulnerability in any skill in this catalog, please **do not** report it through public GitHub issues, discussions, or pull requests.

Instead, report it through the NVIDIA PSIRT process:

- Web form: <https://www.nvidia.com/en-us/security/psirt-policies/>
- Email: <psirt@nvidia.com>

Please include enough information to reproduce the issue:

- The skill name and the file(s) involved
- The Jetson SKU and L4T version
- The agent and version
- A clear description of the vulnerability and reproduction steps
- The potential impact

## Scope

This policy covers the contents of this repository: skill instructions (`SKILL.md`), helper scripts in each skill's `scripts/` directory, and reference material under `references/`.

Vulnerabilities in upstream components (Jetson Linux, CUDA, vLLM, llama.cpp, Ollama, the agents themselves) should be reported to those projects directly.

## Disclosure Policy

NVIDIA follows a coordinated disclosure model. We will work with you to validate, fix, and disclose the issue responsibly.
