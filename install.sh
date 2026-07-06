#!/usr/bin/env sh
# wibx-skills — public one-command installer for the core token economy pack
# (rtk, graphify, caveman, ponytail) + the full wibx skills catalog.
#
#   curl -fsSL https://raw.githubusercontent.com/Wibx-LABS/wibx-skills/main/install.sh | sh
#   # from a clone:
#   sh install.sh [--tools-only|--skills-only] [--no-tools] [--desktop] [--dry-run] [--check]
#
# Self-contained: no devkit needed. All install logic lives in scripts/install.py (stdlib).
set -e

REPO_URL="https://github.com/Wibx-LABS/wibx-skills"
DEST="${WIBX_SKILLS_HOME:-$HOME/.wibx-skills}"

# Locate a local checkout (empty when piped through curl | sh). Try the script's
# own directory (when $0 carries a path) and the current directory.
SELF="$0"
DIR=""
case "$SELF" in
  */*) DIR=$(CDPATH= cd -- "$(dirname -- "$SELF")" && pwd) ;;
esac
REPO=""
for cand in "$DIR" "$PWD"; do
  if [ -n "$cand" ] && [ -f "$cand/scripts/install.py" ]; then REPO="$cand"; break; fi
done

if [ -n "$REPO" ]; then
  :                                 # running from a checkout
elif [ -d "$DEST/.git" ]; then
  echo "updating $DEST"
  git -C "$DEST" fetch -q origin && git -C "$DEST" checkout -q main \
    && git -C "$DEST" pull -q --ff-only || true
  REPO="$DEST"
else
  echo "cloning $REPO_URL -> $DEST"
  git clone -q "$REPO_URL" "$DEST"
  REPO="$DEST"
fi

command -v python3 >/dev/null 2>&1 || { echo "python3 required" >&2; exit 1; }

python3 "$REPO/scripts/install.py" "$@"

# PATH hint for the rtk binary target.
BIN="$HOME/.local/bin"
case ":$PATH:" in
  *":$BIN:"*) ;;
  *) echo "  note: add rtk to PATH ->  export PATH=\"$BIN:\$PATH\"" ;;
esac
