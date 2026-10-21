#!/bin/zsh
# Ferramentas do objeto 3D (lições H10, E11): confere o que existe e, com --install, instala só o que
# aquele caminho de conversão precisa. A conferência não instala nada; --install só com o OK do usuário.
#
# uso: setup_3d.sh                    confere e lista o que falta
#      setup_3d.sh --install <tipo>   instala o que falta para o tipo:
#        blend   Blender + venv   (blender_to_webp.py)
#        frames  venv             (frames_to_webp.py)
#        video   ffmpeg + venv    (video_to_webp.py)
# venv: ~/.venvs/apthtml (APTHTML_VENV muda o caminho), versões fixas medidas em 2026-10-21 no Python 3.14.
# Blender e ffmpeg vêm do Homebrew; o cask do Blender só instala o Blender.app (o blender_to_webp.py o acha).
# saída: 0 = pronto; 1 = falta algo ou a instalação falhou; 2 = sem Homebrew; 3 = uso errado
set -e
VENV=${APTHTML_VENV:-$HOME/.venvs/apthtml}
PKGS=(pillow==13.0.0 numpy==2.5.4 psd-tools==1.26.0)
BLENDER_APP=/Applications/Blender.app/Contents/MacOS/Blender

has_venv()    { [ -x "$VENV/bin/python" ] && "$VENV/bin/python" -c 'import PIL, numpy, psd_tools' 2>/dev/null; }
has_ffmpeg()  { command -v ffmpeg >/dev/null 2>&1; }
has_blender() { { [ -n "$BLENDER" ] && [ -x "$BLENDER" ]; } || command -v blender >/dev/null 2>&1 || [ -x "$BLENDER_APP" ]; }
typeset -A USE=(venv "blend, frames, video" ffmpeg "video" blender "blend")

if [ $# -eq 0 ]; then
  miss=0
  for t in venv ffmpeg blender; do
    if has_$t; then echo "ok     $t"; else echo "falta  $t (para: $USE[$t])"; miss=1; fi
  done
  [ $miss = 0 ] && exit 0
  echo "instalar: $0 --install blend|frames|video (peça OK ao usuário antes)" >&2
  exit 1
fi

[ "$1" = --install ] && [ $# -eq 2 ] || { echo "uso: $0 [--install blend|frames|video]" >&2; exit 3; }
case $2 in
  blend)  need=(venv blender) ;;
  frames) need=(venv) ;;
  video)  need=(venv ffmpeg) ;;
  *) echo "tipo inválido: $2 (blend, frames ou video)" >&2; exit 3 ;;
esac

for t in $need; do
  if has_$t; then echo "ok     $t"; continue; fi
  if [ $t = venv ]; then
    [ -x "$VENV/bin/python" ] || python3 -m venv "$VENV"
    "$VENV/bin/pip" install --quiet "${PKGS[@]}"
  else
    command -v brew >/dev/null 2>&1 || { echo "Homebrew não encontrado: instale em https://brew.sh e rode de novo" >&2; exit 2; }
    if [ $t = ffmpeg ]; then brew install ffmpeg; else brew install --cask blender; fi
  fi
  if has_$t; then echo "instalado $t"; else echo "falhou ao instalar $t" >&2; exit 1; fi
done
