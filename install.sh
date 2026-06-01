#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Install Jetson Platform Skills into the user-home and project dirs that
# Claude Code, Codex, and Cursor read from.
#
# Safe to re-run: correct links are left untouched, and stale Jetson links are
# repaired to point at this clone. Existing non-symlink files/dirs are skipped
# unless --force is passed.
#
# Usage:
#   ./install.sh                                      # all personal targets
#   ./install.sh --targets claude,cursor              # selected personal targets
#   ./install.sh --targets cursor-project --project . # project-local Cursor install
#   ./install.sh --targets nemoclaw --nemoclaw-sandbox jetson-skills
#   ./install.sh --copy                               # copy instead of symlink
#   ./install.sh --force                              # replace existing Jetson skill dirs
#
# Targets:
#   claude  → ~/.claude/skills/   and ~/.claude/agents/
#   codex   → ~/.codex/skills/    and ~/.agents/skills/
#   cursor  → ~/.cursor/skills/
#   cursor-project → <project>/.cursor/skills/
#   nemoclaw → running NemoClaw/OpenClaw sandbox via `nemoclaw <sandbox> skill install`

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE=symlink
TARGETS="claude,codex,cursor"
PROJECT_DIR=""
NEMOCLAW_SANDBOX="jetson-skills"
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --copy) MODE=copy; shift ;;
    --force) FORCE=1; shift ;;
    --targets)
      [ $# -ge 2 ] || { echo "--targets requires a value (e.g. claude,codex,cursor,cursor-project)"; exit 1; }
      TARGETS="$2"; shift 2 ;;
    --targets=*) TARGETS="${1#--targets=}"; shift ;;
    --project)
      [ $# -ge 2 ] || { echo "--project requires a path"; exit 1; }
      PROJECT_DIR="$2"; shift 2 ;;
    --project=*) PROJECT_DIR="${1#--project=}"; shift ;;
    --nemoclaw-sandbox)
      [ $# -ge 2 ] || { echo "--nemoclaw-sandbox requires a sandbox name"; exit 1; }
      NEMOCLAW_SANDBOX="$2"; shift 2 ;;
    --nemoclaw-sandbox=*) NEMOCLAW_SANDBOX="${1#--nemoclaw-sandbox=}"; shift ;;
    --help|-h)
      sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

# ── helpers ──────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}  ✓${NC} $*"; }
skip() { echo -e "${YELLOW}  ~${NC} $*"; }
err()  { echo -e "${RED}  ✗${NC} $*"; }
info() { echo -e "${BLUE}  i${NC} $*"; }

want_target() {
  # returns 0 if $1 is in the comma-separated TARGETS list
  case ",${TARGETS}," in
    *,"$1",*) return 0 ;;
    *) return 1 ;;
  esac
}

install_entry() {
  local src="$1" dst="$2"
  local name; name="$(basename "$src")"

  if [ "$MODE" = symlink ]; then
    if [ -L "$dst" ]; then
      local current; current="$(readlink "$dst")"
      if [ "$current" = "$src" ]; then
        skip "$name (already linked)"
        return
      else
        skip "$name (repairing stale link: $current)"
        rm "$dst"
      fi
    elif [ -e "$dst" ]; then
      if [ "$FORCE" -eq 1 ] && is_jetson_entry "$dst"; then
        skip "$name (replacing existing Jetson entry because --force was passed)"
        rm -rf "$dst"
      else
        err "$name — $dst exists and is not a symlink; skipping (use --force to replace Jetson entries)"
        return
      fi
    fi
    ln -s "$src" "$dst"
    ok "$name → $src"
  else
    if [ -e "$dst" ]; then
      if [ "$FORCE" -eq 1 ] && is_jetson_entry "$dst"; then
        skip "$name (replacing existing Jetson entry because --force was passed)"
        rm -rf "$dst"
      else
        err "$name — $dst exists; skipping (use --force to replace Jetson entries)"
        return
      fi
    fi
    if [ -d "$src" ]; then
      rm -rf "$dst"
      cp -r "$src" "$dst"
    else
      cp "$src" "$dst"
    fi
    ok "$name (copied)"
  fi
}

is_jetson_entry() {
  local path="$1"
  local base; base="$(basename "$path")"
  case "$base" in
    jetson-*) ;;
    *) return 1 ;;
  esac
  if [ -L "$path" ]; then
    return 0
  fi
  [ -e "$path/SKILL.md" ] || [ "${base##*.}" = "md" ]
}

install_skills_into() {
  local dst_dir="$1" label="$2"
  mkdir -p "$dst_dir"
  echo ""
  echo "[$label] Skills → $dst_dir"
  for src in "$SKILLS_SRC"/*/; do
    src="${src%/}"                    # strip trailing slash
    name="$(basename "$src")"
    install_entry "$src" "$dst_dir/$name"
  done
  verify_skill_root "$dst_dir" "$label"
}

install_nemoclaw_skills() {
  command -v nemoclaw >/dev/null 2>&1 || {
    err "nemoclaw CLI not found; install NemoClaw first or omit target 'nemoclaw'"
    return 1
  }
  command -v openshell >/dev/null 2>&1 || {
    err "openshell CLI not found; install NemoClaw/OpenShell first or omit target 'nemoclaw'"
    return 1
  }

  echo ""
  echo "[nemoclaw] Skills → sandbox ${NEMOCLAW_SANDBOX}:/sandbox/.openclaw/skills"
  for src in "$SKILLS_SRC"/jetson-*/; do
    [ -d "$src" ] || continue
    name="$(basename "${src%/}")"
    if nemoclaw "$NEMOCLAW_SANDBOX" skill install "$src"; then
      ok "$name installed"
    else
      err "$name failed to install into NemoClaw sandbox"
      return 1
    fi
  done

  if timeout 15s openshell sandbox exec -n "$NEMOCLAW_SANDBOX" -- sh -lc "count=\$(find /sandbox/.openclaw/skills -maxdepth 2 -name SKILL.md | wc -l); printf 'NemoClaw skill root contains %s SKILL.md files\n' \"\$count\""; then
    ok "nemoclaw verified"
  else
    skip "nemoclaw final verification timed out; skills were uploaded, start a fresh OpenClaw session before testing"
  fi
}

verify_skill_root() {
  local dst_dir="$1" label="$2"
  local missing=0 checked=0
  for src in "$SKILLS_SRC"/jetson-*/; do
    [ -d "$src" ] || continue
    local name; name="$(basename "${src%/}")"
    checked=$((checked + 1))
    if [ ! -f "$dst_dir/$name/SKILL.md" ]; then
      missing=$((missing + 1))
    fi
  done
  if [ "$missing" -eq 0 ]; then
    ok "$label verified ($checked skills visible)"
  else
    err "$label verification failed ($missing of $checked skills missing)"
  fi
}

# ── validate targets ─────────────────────────────────────────────────────────

for t in ${TARGETS//,/ }; do
  case "$t" in
    claude|codex|cursor|cursor-project|nemoclaw) ;;
    *) echo "Unknown target: '$t' (valid: claude, codex, cursor, cursor-project, nemoclaw)"; exit 1 ;;
  esac
done

if want_target cursor-project; then
  if [ -z "$PROJECT_DIR" ]; then
    echo "--project is required when using --targets cursor-project" >&2
    exit 1
  fi
  if [ ! -d "$PROJECT_DIR" ]; then
    echo "--project path does not exist or is not a directory: $PROJECT_DIR" >&2
    exit 1
  fi
  PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
fi

SKILLS_SRC="$REPO_DIR/skills"
AGENTS_SRC="$REPO_DIR/agents"

echo "Mode: $MODE"
echo "Targets: $TARGETS"
echo "Source: $REPO_DIR"
if [ -n "$PROJECT_DIR" ]; then
  echo "Project: $PROJECT_DIR"
fi

# ── claude ───────────────────────────────────────────────────────────────────

if want_target claude; then
  install_skills_into "${HOME}/.claude/skills" "claude"

  AGENTS_DST="${HOME}/.claude/agents"
  mkdir -p "$AGENTS_DST"
  echo ""
  echo "[claude] Agents → $AGENTS_DST"
  for src in "$AGENTS_SRC"/*.md; do
    [ -f "$src" ] || continue
    name="$(basename "$src")"
    [[ "$name" == README* ]] && continue   # skip documentation
    install_entry "$src" "$AGENTS_DST/$name"
  done
fi

# ── codex (canonical ~/.codex AND legacy ~/.agents) ──────────────────────────

if want_target codex; then
  install_skills_into "${HOME}/.codex/skills"  "codex"
  install_skills_into "${HOME}/.agents/skills" "codex (AGENTS.md)"
fi

# ── cursor ───────────────────────────────────────────────────────────────────

if want_target cursor; then
  install_skills_into "${HOME}/.cursor/skills" "cursor"
  info "Cursor managed skills live in ~/.cursor/skills-cursor; do not install community skills there."
fi

if want_target cursor-project; then
  install_skills_into "${PROJECT_DIR}/.cursor/skills" "cursor-project"
fi

if want_target nemoclaw; then
  install_nemoclaw_skills
fi

echo ""
echo "Done."
echo "Restart Claude Code / Codex / Cursor, or start a new chat/session, to pick up new skill entries."
echo "For NemoClaw/OpenClaw, restart the gateway or start a fresh chat/session after install."
echo "If an agent still does not expose Jetson skills, confirm it reads the target root shown above."
