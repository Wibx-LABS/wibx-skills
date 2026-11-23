#!/usr/bin/env python3
"""Auditoria determinística de SEO técnico + GEO. Só stdlib.

Uso:
  audit.py <pasta-do-build>            # ex.: dist/, out/, build/, _site/
  audit.py https://site.com [--max 30] # site ao vivo: robots, sitemap, llms.txt + páginas do sitemap
  --json                               # saída em JSON em vez de markdown

Saída: achados ERROR / WARN / INFO. Exit 1 se houver ERROR (serve de gate).
"""
import json
import re
import sys
import urllib.request
import urllib.robotparser
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urljoin, urlparse

# Política canônica Wibx (tandera-audit/reference/robots_txt_para_geo.md):
# search + user-fetch sempre liberados; treino é decisão editorial caso a caso.
SEARCH_BOTS = ["Googlebot", "Bingbot", "Applebot", "OAI-SearchBot", "Claude-SearchBot", "PerplexityBot"]
USER_BOTS = ["ChatGPT-User", "Claude-User", "Perplexity-User"]
TRAIN_BOTS = ["GPTBot", "ClaudeBot", "Google-Extended", "Applebot-Extended", "CCBot", "Meta-ExternalAgent", "Bytespider"]
UA = "seo-geo-audit/1.0"


class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.lang = None
        self.title = ""
        self.meta = {}
        self.links = []
        self.h1 = 0
        self.headings = []
        self.jsonld = []
        self.img_no_alt = 0
        self.words = 0
        self._stack = []
        self._buf = ""

    def handle_starttag(self, tag, attrs):
        a = {k: (v or "") for k, v in attrs}
        if tag == "html":
            self.lang = a.get("lang")
        elif tag == "meta":
            key = a.get("name") or a.get("property")
            if key:
                self.meta[key.lower()] = a.get("content", "")
        elif tag == "link":
            self.links.append(a)
        elif tag == "img" and not a.get("alt") and a.get("role") != "presentation" and "alt" not in a:
            self.img_no_alt += 1
        elif tag in ("h1", "h2", "h3", "h4", "h5", "h6"):
            self.headings.append(int(tag[1]))
            if tag == "h1":
                self.h1 += 1
        self._stack.append((tag, a))
        self._buf = ""

    def handle_endtag(self, tag):
        if self._stack and self._stack[-1][0] == tag:
            t, a = self._stack.pop()
            if t == "title":
                self.title = self._buf.strip()
            elif t == "script" and a.get("type") == "application/ld+json":
                self.jsonld.append(self._buf)
        self._buf = ""

    def handle_data(self, data):
        self._buf += data
        top = self._stack[-1][0] if self._stack else ""
        if top not in ("script", "style", "title", "noscript", "template"):
            self.words += len(data.split())


def jsonld_types(raw):
    data = json.loads(raw)
    items = data if isinstance(data, list) else data.get("@graph", [data])
    out = []
    for it in items:
        t = it.get("@type") if isinstance(it, dict) else None
        out += t if isinstance(t, list) else [t] if t else []
    return out


def audit_page(name, html, seen):
    p = Page()
    p.feed(html)
    f = []
    add = lambda lvl, msg: f.append((lvl, name, msg))

    if "noindex" in p.meta.get("robots", ""):
        # fora do índice por decisão: checar SEO aqui só gera ruído
        add("INFO", "noindex — checagens de SEO puladas (confirme que é intencional)")
        return f
    if not p.lang:
        add("ERROR", "<html> sem atributo lang")
    if not p.title:
        add("ERROR", "sem <title>")
    elif len(p.title) > 60:
        add("WARN", f"<title> com {len(p.title)} chars (>60 é truncado na SERP)")
    d = p.meta.get("description", "")
    if not d:
        add("ERROR", "sem meta description")
    elif not 50 <= len(d) <= 160:
        add("WARN", f"meta description com {len(d)} chars (ideal 50–160)")
    if p.h1 != 1:
        add("ERROR", f"{p.h1} <h1> (deve ser exatamente 1)")
    for prev, cur in zip(p.headings, p.headings[1:]):
        if cur > prev + 1:
            add("WARN", f"salto de heading h{prev}→h{cur}")
            break

    canon = [l.get("href", "") for l in p.links if l.get("rel") == "canonical"]
    if not canon:
        add("ERROR", "sem <link rel=canonical>")
    elif not canon[0].startswith("http"):
        add("WARN", f"canonical relativo: {canon[0]} (use URL absoluta)")
    hl = [l.get("hreflang") for l in p.links if l.get("rel") == "alternate" and l.get("hreflang")]
    if hl and "x-default" not in hl:
        add("WARN", f"hreflang {hl} sem x-default")

    for k in ("og:title", "og:description", "og:image", "og:url"):
        if k not in p.meta:
            add("WARN", f"sem {k}")
    if "twitter:card" not in p.meta:
        add("WARN", "sem twitter:card")

    types = []
    for raw in p.jsonld:
        try:
            types += jsonld_types(raw)
            seen.update(map(str, types))
        except (ValueError, AttributeError) as e:
            add("ERROR", f"JSON-LD inválido: {e}")
    if not p.jsonld:
        add("WARN", "sem JSON-LD (structured data)")
    else:
        add("INFO", f"JSON-LD: {', '.join(map(str, types)) or '(sem @type)'}")

    if p.img_no_alt:
        add("WARN", f"{p.img_no_alt} <img> sem alt")
    if p.words < 80:
        add("ERROR", f"só {p.words} palavras no HTML — conteúdo depende de JS; crawlers de IA não executam JS (prerender/SSR)")
    return f


def audit_site(base, robots_txt, sitemap_xml, llms_txt):
    f = []
    add = lambda lvl, msg: f.append((lvl, "(site)", msg))
    if robots_txt is None:
        add("ERROR", "sem robots.txt")
    else:
        rp = urllib.robotparser.RobotFileParser()
        rp.parse(robots_txt.splitlines())
        probe = urljoin(base or "https://x/", "/")
        for bot in SEARCH_BOTS:
            if not rp.can_fetch(bot, probe):
                add("ERROR", f"robots.txt bloqueia {bot} (search) — some do índice/citações")
        for bot in USER_BOTS:
            if not rp.can_fetch(bot, probe):
                add("WARN", f"robots.txt bloqueia {bot} (fetch do usuário)")
        train = [b for b in TRAIN_BOTS if not rp.can_fetch(b, probe)]
        add("INFO", f"bots de treino bloqueados: {', '.join(train) or 'nenhum'} (decisão editorial)")
        if not re.search(r"(?im)^sitemap:\s*\S+", robots_txt):
            add("WARN", "robots.txt sem linha Sitemap:")
    if sitemap_xml is None:
        add("ERROR", "sem sitemap.xml")
    else:
        locs = re.findall(r"<loc>\s*(.*?)\s*</loc>", sitemap_xml)
        add("INFO", f"sitemap.xml: {len(locs)} URLs")
        if 'hreflang' not in sitemap_xml and len(locs) > 1:
            add("INFO", "sitemap sem xhtml:link hreflang (ok se hreflang está no <head>)")
    if llms_txt is not None:
        add("INFO", "llms.txt presente (só tem efeito em site de documentação — gotchas_2026 §6)")
    return f


def fetch(url):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": UA})
        with urllib.request.urlopen(req, timeout=15) as r:
            return r.read().decode("utf-8", "replace") if r.status == 200 else None
    except Exception:
        return None


def run(target, max_pages):
    findings, seen = [], set()
    if target.startswith("http"):
        base = target.rstrip("/") + "/"
        robots, sitemap, llms = (fetch(urljoin(base, p)) for p in ("robots.txt", "sitemap.xml", "llms.txt"))
        findings += audit_site(base, robots, sitemap, llms)
        urls = re.findall(r"<loc>\s*(.*?)\s*</loc>", sitemap or "")[:max_pages] or [base]
        for u in urls:
            html = fetch(u)
            if html is None:
                findings.append(("ERROR", urlparse(u).path or "/", "não respondeu 200"))
            else:
                findings += audit_page(urlparse(u).path or "/", html, seen)
    else:
        root = Path(target)
        read = lambda n: (root / n).read_text("utf-8", "replace") if (root / n).is_file() else None
        sitemap = read("sitemap.xml")
        m = re.search(r"<loc>\s*(https?://[^/<]+)", sitemap or "")
        findings += audit_site(m.group(1) if m else None, read("robots.txt"), sitemap, read("llms.txt"))
        pages = sorted(root.rglob("*.html"))
        if not pages:
            findings.append(("ERROR", str(root), "nenhum .html — rode o build antes"))
        for page in pages:
            findings += audit_page("/" + str(page.relative_to(root)), page.read_text("utf-8", "replace"), seen)
    if not seen & {"Organization", "Corporation", "LocalBusiness"}:
        findings.append(("WARN", "(site)", "nenhuma página com JSON-LD Organization — entidade da marca invisível para IAs"))
    if "WebSite" not in seen:
        findings.append(("WARN", "(site)", "nenhuma página com JSON-LD WebSite"))
    return findings


def main(argv):
    if not argv or argv[0] in ("-h", "--help"):
        print(__doc__)
        return 2
    max_pages = int(argv[argv.index("--max") + 1]) if "--max" in argv else 30
    findings = run(argv[0], max_pages)
    order = {"ERROR": 0, "WARN": 1, "INFO": 2}
    findings.sort(key=lambda x: (order[x[0]], x[1]))
    if "--json" in argv:
        print(json.dumps([{"level": l, "where": w, "msg": m} for l, w, m in findings], ensure_ascii=False, indent=2))
    else:
        counts = {k: sum(1 for f in findings if f[0] == k) for k in order}
        print(f"# Auditoria SEO/GEO — {argv[0]}\n\n{counts['ERROR']} ERROR · {counts['WARN']} WARN · {counts['INFO']} INFO\n")
        print("| nível | onde | achado |\n|---|---|---|")
        for l, w, m in findings:
            m = m.replace("|", "\\|")
            print(f"| {l} | `{w}` | {m} |")
    return 1 if any(f[0] == "ERROR" for f in findings) else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
