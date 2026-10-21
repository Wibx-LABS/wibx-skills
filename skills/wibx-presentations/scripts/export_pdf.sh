#!/bin/zsh
# Exporta o deck para PDF (Chrome headless) e gera folha(s) de conferência renderizadas pelo MESMO motor
# do Preview do Mac (Quartz via pdfseparate + sips). Ver references/licoes.md E17 e E10.
#
# uso: export_pdf.sh <Deck.html> [páginas...]
#   saída: 0 ok; 2 Chrome não encontrado; 3 PDF gerado mas folha de conferência NÃO gerada (falta Pillow no python3 do PATH)
#   sem páginas: confere todas. Saída: <Deck>.pdf ao lado do HTML e folhas em $TMPDIR/apthtml-pdf/sheetN.png
#
# Pré-requisitos no deck: @page { size: 1920px 1080px; margin: 0 } e o @media print sem backdrop-filter,
# drop-shadow e box-shadow com blur (o Quartz desenha retângulo escuro). Animações: o export liga
# reduced-motion, então o quadro 0 de cada animação é o que vai para o PDF (deixe-o como a pose principal).
set -e
HTML=${1:?uso: export_pdf.sh Deck.html [páginas...]}
shift
HTML=$(cd "$(dirname "$HTML")" && pwd)/$(basename "$HTML")
PDF=${HTML%.html}.pdf
OUT=${TMPDIR:-/tmp}/apthtml-pdf
CHROME=${CHROME:-"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"}
[ -x "$CHROME" ] || { echo "Chrome não encontrado: defina CHROME=<caminho>" >&2; exit 2; }

# caminho ABSOLUTO em --print-to-pdf (relativo falha em silêncio)
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-prefers-reduced-motion \
  --run-all-compositor-stages-before-draw --virtual-time-budget=15000 --no-pdf-header-footer \
  --print-to-pdf="$PDF" "file://$HTML" 2>/dev/null
echo "PDF: $PDF ($(( $(stat -f%z "$PDF") / 1024 )) KB, $(pdfinfo "$PDF" | awk '/^Pages/{print $2}') páginas)"

mkdir -p "$OUT"
rm -f "$OUT"/pg-*(N)
pdfseparate "$PDF" "$OUT/pg-%02d.pdf"
for f in "$OUT"/pg-*.pdf; do sips -s format png "$f" --out "${f%.pdf}.png" >/dev/null 2>&1; rm "$f"; done

python3 -c 'import PIL' 2>/dev/null || {
  echo "PDF gerado, mas a folha de conferência Quartz (lições E17) foi PULADA: Pillow não está instalado no python3 do PATH ($(command -v python3)). Instale com: python3 -m pip install Pillow" >&2
  exit 3
}
python3 - "$OUT" "$@" <<'PY'
import sys, glob
from PIL import Image
out = sys.argv[1]
pages = [int(a) for a in sys.argv[2:]] or list(range(1, len(glob.glob(f"{out}/pg-*.png")) + 1))
W, H = 960, 540
for k in range(0, len(pages), 6):
    part = pages[k:k + 6]
    rows = (len(part) + 1) // 2
    s = Image.new("RGB", (W * 2, H * rows), "white")
    for i, p in enumerate(part):
        s.paste(Image.open(f"{out}/pg-{p:02d}.png").convert("RGB").resize((W, H)), ((i % 2) * W, (i // 2) * H))
    s.save(f"{out}/sheet{k // 6}.png")
    print(f"{out}/sheet{k // 6}.png <- páginas {part}")
PY
