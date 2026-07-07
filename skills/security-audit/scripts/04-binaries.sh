#!/usr/bin/env bash
# Detect pre-compiled executables and suspicious binary artifacts in source repos.
set -uo pipefail

TARGET="${1:-.}"

echo ""
echo "=== SCAN 04: Binaries & Executables ==="

FOUND=0
EXCLUDE="\.git|node_modules|vendor|\.venv|venv"

# ── Detect compiled binaries via file type ─────────────────────────────────────
echo "[INFO] Scanning for compiled executables..."
# Newline-delimited (not -print0/read -d '') for macOS bash 3.2 compatibility.
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    ftype=$(file -b "$f" 2>/dev/null || true)
    case "$ftype" in
      ELF*|"Mach-O"*|"PE32"*|"MS-DOS"*|"COM executable"*)
        echo "[HIGH] Binary executable in source repo: $f"
        echo "  Type: $ftype"
        FOUND=1
        ;;
      *"dynamically linked"*|*"shared object"*)
        echo "[MEDIUM] Shared library in source repo: $f"
        echo "  Type: $ftype"
        FOUND=1
        ;;
    esac
  done < <(find "$TARGET" -type f \
  ! -path "*/.git/*" \
  ! -path "*/node_modules/*" \
  ! -path "*/vendor/*" \
  ! -path "*/.venv/*" \
  ! -path "*/venv/*" \
  -print 2>/dev/null)

# ── .pyc files outside __pycache__ ────────────────────────────────────────────
echo "[INFO] Checking for compiled Python files outside __pycache__..."
while IFS= read -r f; do
    echo "[MEDIUM] Compiled .pyc outside __pycache__: $f"
    FOUND=1
  done < <(find "$TARGET" -name "*.pyc" -not -path "*/__pycache__/*" \
  ! -path "*/.git/*" 2>/dev/null)

# ── Files with no extension but executable bit ────────────────────────────────
echo "[INFO] Checking for executable files with no extension..."
while IFS= read -r f; do
    ftype=$(file -b "$f" 2>/dev/null || true)
    # Skip shell scripts and text files
    case "$ftype" in
      *"shell script"*|*"ASCII text"*|*"Unicode text"*) continue ;;
    esac
    echo "[MEDIUM] Executable with no extension: $f"
    echo "  Type: $ftype"
    FOUND=1
  done < <(find "$TARGET" -type f -perm /111 \
  ! -name "*.*" \
  ! -path "*/.git/*" \
  ! -path "*/node_modules/.bin/*" \
  ! -path "*/bin/*" \
  -maxdepth 4 2>/dev/null)

# ── Hidden files with executable bit ──────────────────────────────────────────
echo "[INFO] Checking for hidden executable files..."
while IFS= read -r f; do
    basename_f=$(basename "$f")
    # Ignore common dotfiles
    case "$basename_f" in
      .gitignore|.gitattributes|.npmrc|.eslintrc*|.babelrc*|.prettierrc*) continue ;;
    esac
    ftype=$(file -b "$f" 2>/dev/null || true)
    echo "[HIGH] Hidden executable file: $f"
    echo "  Type: $ftype"
    FOUND=1
  done < <(find "$TARGET" -name ".*" -type f -perm /111 \
  ! -path "*/.git/*" \
  -maxdepth 4 2>/dev/null)

# ── .so / .dylib outside expected vendor/lib dirs ─────────────────────────────
while IFS= read -r f; do
    echo "[MEDIUM] Native library outside vendor/lib: $f"
    FOUND=1
  done < <(find "$TARGET" -type f \( -name "*.so" -o -name "*.so.*" -o -name "*.dylib" \) \
  ! -path "*/node_modules/*" \
  ! -path "*/vendor/*" \
  ! -path "*/lib/*" \
  ! -path "*/.git/*" 2>/dev/null)

# Summary export for LLM phase
if [[ "$FOUND" -eq 0 ]]; then
  echo "[INFO] No suspicious binaries found."
fi

exit 0
