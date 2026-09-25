# Vendor: origem de cada pasta

Cópias fiéis dos plugins/skills que o pacote apthtml carrega, trazidas para dentro do pacote
em vez de instaladas como plugin (decisão de 2026-09-24: sem dependência de marketplace de
terceiro; atualização é manual, recopiando). Todas MIT, licença na própria pasta.
`security-audit` rodado em cada repo em 2026-09-24: 0 achados no que foi copiado (só MEDIUMs
nos workflows de CI do upstream, que não vêm junto).

| Pasta | Origem | Commit | Recorte |
|---|---|---|---|
| `frontend-slides/` | github.com/zarazhangrui/frontend-slides `plugins/frontend-slides/skills/frontend-slides` | `9906a34d640d2111f724544cbc50f7f130569ae1` | **sem `scripts/deploy.sh`** (publica na Vercel e faz `npm install -g`; o SKILL.md da skill já proíbe) |
| `diagram-design/` | github.com/cathrynlavery/diagram-design `skills/diagram-design` | `dc1ace47b99a419e42d01a03cb6ace5346efa8ae` | inteiro; `assets/` é a galeria dos 61 modelos |
| `gsap-skills/` | github.com/greensock/gsap-skills `skills/` | `aed9cfd3277740755f6bfc1155c7aa645403b760` | só `gsap-core`, `gsap-timeline`, `gsap-plugins`, `gsap-performance` |
| `taste-skill/design-taste-frontend/` | github.com/Leonxlnx/taste-skill `skills/taste-skill` | `c184364c58658b2f131b4ae8bd3d206cabb3deee` | inteiro |
| `taste-skill/high-end-visual-design/` | idem, `skills/soft-skill` | idem | inteiro |
| `taste-skill/redesign-existing-projects/` | idem, `skills/redesign-skill` | idem | inteiro |
| `frontend-design/` | pacote apthtml (skill da Anthropic, `LICENSE.txt`) | n/a | inteiro |

Para atualizar: clonar o upstream, rodar `security-audit`, recopiar a pasta e trocar o commit aqui.
