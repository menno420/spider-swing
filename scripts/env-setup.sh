#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# scripts/env-setup.sh — environment setup for spider-swing
#
# Installs the ONE dependency this repo actually has: Godot 4.7.1 **Standard**
# (no .NET, ADR 0001). Everything else here is Python stdlib — `tools/verify.py`
# and the vendored `bootstrap.py` import nothing outside it, so there is no
# manifest to install and none is invented.
#
# WHY THIS FILE IS NAMED THIS: fleet-manager's `environments/setup-base.sh`
# auto-discovers `scripts/env-setup.sh` in every child repo, so this works
# unchanged whether spider-swing is a solo environment or a child of a
# coordinator workspace. A fleet archetype for it need only call this file.
#
# CONTRACT (fleet playbook R15): every step is non-fatal and this script
# ALWAYS exits 0. A broken toolchain must degrade to "install it in-session",
# never to a container that refuses to start.
# ---------------------------------------------------------------------------
set +e
export PIP_ROOT_USER_ACTION=ignore
export DEBIAN_FRONTEND=noninteractive

ARCH_NAME="spider-swing"
log() { echo "[env-setup:$ARCH_NAME] $*"; }

REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"

# --- 1 · the pinned engine version comes from the repo, never from here ------
# .godot-version is the single source of truth; tools/verify.py fails the build
# if the running engine disagrees with it. Hard-coding a version in two places
# is how they drift, so this reads it.
GODOT_VERSION="$(tr -d '[:space:]' < "$REPO_ROOT/.godot-version" 2>/dev/null)"
if [ -z "$GODOT_VERSION" ]; then
  GODOT_VERSION="4.7.1"
  log "WARNING: .godot-version unreadable — falling back to $GODOT_VERSION"
fi
log "pinned engine: Godot $GODOT_VERSION Standard"

GODOT_HOME="${GODOT_HOME:-/opt/godot}"
mkdir -p "$GODOT_HOME" 2>/dev/null \
  || { GODOT_HOME="$HOME/.local/share/godot"; mkdir -p "$GODOT_HOME" 2>/dev/null; } \
  || { GODOT_HOME="/tmp/godot"; mkdir -p "$GODOT_HOME" 2>/dev/null; }
GODOT_BIN_PATH="$GODOT_HOME/godot"

# --- 2 · XDG dirs, or Godot aborts with exit 134 ----------------------------
# Headless Godot writes editor/user state at startup. With no writable XDG
# home it dies on SIGABRT (134) with no useful message — this cost a live
# session real time, so it is set before anything tries to run the engine.
export XDG_DATA_HOME="${XDG_DATA_HOME:-/tmp/spider-swing-godot/data}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/tmp/spider-swing-godot/config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/spider-swing-godot/cache}"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" 2>/dev/null

# --- 3 · idempotent install -------------------------------------------------
# Re-running must be cheap: the container image is cached after this script,
# so a warm start should verify and exit rather than re-download 100 MB.
godot_ok() {
  [ -x "$1" ] || return 1
  "$1" --version 2>/dev/null | grep -q "^${GODOT_VERSION}\.stable" || return 1
  # ADR 0001 forbids the .NET build. verify.py rejects it too; catching it
  # here turns a confusing late failure into an early, explicit one.
  "$1" --version 2>/dev/null | grep -qi "mono" && return 1
  return 0
}

if godot_ok "$GODOT_BIN_PATH"; then
  log "Godot $GODOT_VERSION already present at $GODOT_BIN_PATH — skipping download"
else
  ZIP_NAME="Godot_v${GODOT_VERSION}-stable_linux.x86_64"
  URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/${ZIP_NAME}.zip"
  TMP_ZIP="$(mktemp -u /tmp/godot-XXXXXX.zip)"
  log "downloading $URL"
  if curl -fsSL --retry 3 --max-time 300 -o "$TMP_ZIP" "$URL"; then
    command -v unzip >/dev/null 2>&1 \
      || (apt-get update -qq && apt-get install -y -qq unzip) >/dev/null 2>&1 \
      || (sudo apt-get update -qq && sudo apt-get install -y -qq unzip) >/dev/null 2>&1
    if unzip -o -q "$TMP_ZIP" -d "$GODOT_HOME"; then
      # The zip contains the versioned binary name; normalise it so the path
      # is stable across engine bumps and nothing downstream hard-codes 4.7.1.
      if [ -f "$GODOT_HOME/$ZIP_NAME" ]; then
        mv -f "$GODOT_HOME/$ZIP_NAME" "$GODOT_BIN_PATH" 2>/dev/null
      fi
      chmod +x "$GODOT_BIN_PATH" 2>/dev/null
      log "installed to $GODOT_BIN_PATH"
    else
      log "unzip failed (non-fatal) — install Godot in-session if the engine gate is needed"
    fi
    rm -f "$TMP_ZIP" 2>/dev/null
  else
    log "download failed (non-fatal) — install Godot in-session if the engine gate is needed"
  fi
fi

# --- 4 · make it discoverable ----------------------------------------------
# verify.py looks for GODOT_BIN / GODOT / GODOT4, then 'godot' on PATH.
# Both are provided: the env var for this process tree, the symlink for any
# shell that starts without the env file.
if godot_ok "$GODOT_BIN_PATH"; then
  export GODOT_BIN="$GODOT_BIN_PATH"
  for d in /usr/local/bin "$HOME/.local/bin"; do
    mkdir -p "$d" 2>/dev/null && ln -sf "$GODOT_BIN_PATH" "$d/godot" 2>/dev/null && break
  done
  log "verified: $("$GODOT_BIN_PATH" --version 2>/dev/null)"
else
  log "WARNING: no working Godot at $GODOT_BIN_PATH"
  log "  tools/verify.py still runs; --require-godot will fail until one exists."
fi

# --- 5 · persist for every later shell in the session -----------------------
# ONE sentinel-delimited block, rewritten in place. An append-if-grep-misses
# approach looks idempotent and is not: the first version of this file grepped
# for GODOT_BIN=/path while writing GODOT_BIN="/path", so the guard never
# matched and every run appended another copy. A delimited block cannot drift
# that way -- it is deleted and rewritten, so N runs leave exactly one copy.
BEGIN_MARK="# >>> spider-swing env-setup >>>"
END_MARK="# <<< spider-swing env-setup <<<"

write_block() {
  target="$1"
  [ -n "$target" ] || return 0
  touch "$target" 2>/dev/null || return 0
  # Drop any previous block, then append the current one.
  tmp="$(mktemp 2>/dev/null)" || return 0
  sed "/$BEGIN_MARK/,/$END_MARK/d" "$target" > "$tmp" 2>/dev/null && mv -f "$tmp" "$target" 2>/dev/null
  {
    printf '%s\n' "$BEGIN_MARK"
    [ -n "${GODOT_BIN:-}" ] && printf 'export GODOT_BIN=%s\n' "\"$GODOT_BIN_PATH\""
    printf 'export XDG_DATA_HOME=%s\n'   "\"$XDG_DATA_HOME\""
    printf 'export XDG_CONFIG_HOME=%s\n' "\"$XDG_CONFIG_HOME\""
    printf 'export XDG_CACHE_HOME=%s\n'  "\"$XDG_CACHE_HOME\""
    printf '%s\n' "$END_MARK"
  } >> "$target" 2>/dev/null
}

write_block "$HOME/.bashrc"
# CLAUDE_ENV_FILE is consumed once per session, so it takes a plain append.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  {
    [ -n "${GODOT_BIN:-}" ] && printf 'export GODOT_BIN=%s\n' "\"$GODOT_BIN_PATH\""
    printf 'export XDG_DATA_HOME=%s\n'   "\"$XDG_DATA_HOME\""
    printf 'export XDG_CONFIG_HOME=%s\n' "\"$XDG_CONFIG_HOME\""
    printf 'export XDG_CACHE_HOME=%s\n'  "\"$XDG_CACHE_HOME\""
  } >> "$CLAUDE_ENV_FILE" 2>/dev/null
fi

# --- 6 · optional extras, never required ------------------------------------
# imageio-ffmpeg is the only third-party package this repo has ever needed:
# it decodes owner gameplay recordings for the calibration measurements. No
# tool imports it, so its absence breaks nothing.
python3 -m pip install --quiet imageio-ffmpeg >/dev/null 2>&1 \
  && log "optional: imageio-ffmpeg installed (owner-recording analysis)" \
  || log "optional: imageio-ffmpeg unavailable (fine — nothing imports it)"

log "ready. Gates: 'python3 tools/verify.py --require-godot' and 'python3 bootstrap.py check --strict'"
exit 0
