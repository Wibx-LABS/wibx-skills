#!/usr/bin/env python3
"""Falha se um SKILL.md manda ler um arquivo que o pacote da skill não entrega.

Motivo: `package_skill.py` empacota `skills/<nome>/` inteiro (rglob), então tudo
que a skill precisa em runtime tem que morar dentro da própria pasta. Uma citação
a `references/x.md` que não existe ali vira instrução impossível de cumprir depois
de instalada — o agente tenta abrir, não acha, e segue sem o conteúdo.

Uso: python scripts/validate_refs.py skills/<nome>
     python scripts/validate_refs.py --selftest

ponytail: heurística de texto, não parser de markdown. Só acusa caminho relativo
citado em contexto de leitura. Se voltar ruído, o upgrade é uma allowlist por
skill (`# validate-refs: ignore <caminho>` na linha) em vez de afrouxar a regex.
"""
import re
import sys
from pathlib import Path

PREFIXES = ("references", "assets", "examples", "templates", "scripts")

# Lookbehind mata caminho com prefixo de outra skill (`swarm/scripts/x.sh`,
# `skills/swarm/references/y.md`) e invocação de shell (`./scripts/x.sh`):
# esses não são promessa do pacote desta skill.
PATH_RE = re.compile(r"(?<![\w/.\-])(?:" + "|".join(PREFIXES) + r")/[\w\-./]+\.\w+")

# Marcadores de intenção de LEITURA. Sem um deles na linha, a menção é prosa
# (descrever o script de outra skill) ou instrução de criação ("Save as ...").
READ_MARKERS = (
    "leia", "ler ", "veja", "ver ", "consulte", "consultar", "detalhe",
    "detalhes", "referência", "referencia", "use ", "usar", "carregue",
    "read", "see ", "consult", "detail", "details", "refer", "load",
)


def dangling_refs(skill_md: str, shipped: set) -> list:
    """Caminhos citados para leitura que não existem no pacote."""
    out = []
    for lineno, line in enumerate(skill_md.splitlines(), 1):
        low = line.lower()
        if not any(m in low for m in READ_MARKERS):
            continue
        for path in PATH_RE.findall(line):
            if path not in shipped:
                out.append((lineno, path))
    return out


def validate(skill_dir: Path):
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        return False, f"{skill_md} não existe."
    shipped = {
        str(p.relative_to(skill_dir)) for p in skill_dir.rglob("*") if p.is_file()
    }
    missing = dangling_refs(skill_md.read_text(encoding="utf-8"), shipped)
    if not missing:
        return True, "OK"
    seen, lines = set(), []
    for lineno, path in missing:
        if path in seen:
            continue
        seen.add(path)
        lines.append(f"  linha {lineno}: {path}")
    return False, (
        f"{len(seen)} caminho(s) citado(s) para leitura não existem no pacote "
        f"— adicione o arquivo em {skill_dir}/ ou corrija a citação:\n"
        + "\n".join(lines)
    )


def selftest():
    shipped = {"SKILL.md", "references/real.md"}
    cases = [
        ("Detalhes em `references/real.md`.", 0, "caminho que existe passa"),
        ("Detalhes em `references/fantasma.md`.", 1, "caminho ausente falha"),
        ("Save as `scripts/ship.sh`:", 0, "instrução de criação não é leitura"),
        ("`scripts/x.sh` executa npm audit no alvo.", 0, "prosa não é leitura"),
        ("Veja `swarm/references/protocolo.md` da skill base.", 0,
         "prefixo de outra skill é ignorado"),
        ("Use `assets/p1/templates/t.json` para estruturar.", 1,
         "caminho completo é casado inteiro, não pelo sufixo"),
        ("chmod +x scripts/ship.sh && ./scripts/ship.sh 1.0", 0,
         "invocação de shell não é leitura"),
    ]
    for text, expected, msg in cases:
        got = len(dangling_refs(text, shipped))
        assert got == expected, f"{msg}: esperado {expected}, obtido {got} — {text!r}"
    print(f"selftest OK ({len(cases)} casos)")


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--selftest":
        selftest()
        sys.exit(0)
    if len(sys.argv) != 2:
        print("Uso: python scripts/validate_refs.py <skill_directory>")
        sys.exit(1)
    ok, message = validate(Path(sys.argv[1]))
    print(message)
    sys.exit(0 if ok else 1)
