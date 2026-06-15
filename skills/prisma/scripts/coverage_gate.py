#!/usr/bin/env python3
"""
coverage_gate.py — valida Evidence Pack contra o Gate 1 do pipeline PRISMA.

Uso:
    python coverage_gate.py path/to/evidence_pack.json

Sai com código 0 se passou; código 1 se bloqueou; código 2 se erro de leitura.
"""

import json
import sys
from pathlib import Path

MIN_POSTS = 10
MIN_COMMENTS_MADE = 10
MIN_CHAR_COUNT = 3000

FORBIDDEN_PHRASES = [
    "provavelmente",
    "tende a",
    "parece que",
    "em geral",
    "imagino que",
    "probably",
    "tends to",
    "seems like",
    "in general",
    "i imagine",
]


def load_pack(path: Path) -> dict:
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"ERRO: arquivo não encontrado: {path}", file=sys.stderr)
        sys.exit(2)
    except json.JSONDecodeError as e:
        print(f"ERRO: JSON inválido: {e}", file=sys.stderr)
        sys.exit(2)


def count_chars(pack: dict) -> int:
    total = 0
    for item in pack.get("content_items", []):
        total += len(item.get("text", ""))
    for c in pack.get("comments_made", []):
        total += len(c.get("text", ""))
    return total


def find_forbidden_phrases(pack: dict) -> list:
    found = []
    text_blob = json.dumps(pack, ensure_ascii=False).lower()
    for phrase in FORBIDDEN_PHRASES:
        if phrase in text_blob:
            found.append(phrase)
    return found


def validate(pack: dict) -> tuple[bool, list, dict]:
    blockers = []

    # Synthetic_no_anchor bypass: still validate forbidden phrases, skip count gates
    is_synthetic = pack.get("status") == "synthetic_no_anchor"
    if is_synthetic and not pack.get("disclosure"):
        blockers.append("status=synthetic_no_anchor requires non-empty 'disclosure' field")

    posts = len(pack.get("content_items", []))
    comments = len(pack.get("comments_made", []))
    chars = count_chars(pack)

    identity = pack.get("identity_snapshot", {})
    has_identity = bool(identity.get("name"))

    if not has_identity:
        blockers.append("identity_snapshot.name is empty")

    if not is_synthetic:
        if posts < MIN_POSTS:
            blockers.append(f"posts_count={posts} < {MIN_POSTS}")
        if comments < MIN_COMMENTS_MADE:
            blockers.append(f"comments_made_count={comments} < {MIN_COMMENTS_MADE}")
        if chars < MIN_CHAR_COUNT:
            blockers.append(f"total_char_count={chars} < {MIN_CHAR_COUNT}")

    forbidden = find_forbidden_phrases(pack)
    if forbidden:
        blockers.append(f"forbidden_phrases_found: {forbidden}")

    summary = {
        "posts_count": posts,
        "comments_made_count": comments,
        "total_char_count": chars,
        "has_identity": has_identity,
        "synthetic_no_anchor": is_synthetic,
        "forbidden_phrases_found": forbidden,
    }
    return (len(blockers) == 0), blockers, summary


def main():
    if len(sys.argv) != 2:
        print("Uso: python coverage_gate.py <path/to/evidence_pack.json>", file=sys.stderr)
        sys.exit(2)

    path = Path(sys.argv[1])
    pack = load_pack(path)
    passed, blockers, summary = validate(pack)

    print(json.dumps({
        "passed": passed,
        "summary": summary,
        "blockers": blockers,
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if passed else 1)


if __name__ == "__main__":
    main()
