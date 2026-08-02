# Pack de prompts Wibx — conjunto canônico de SoV

> v1.0 (2026-08-02). Deriva do baseline audit de 2026-05-04 (famílias A-G), atualizado: WLs corrigidos per Bíblia THANOS (roster real = **BORA, Music Lovers, Wibx**; Gate0/WomanX/Amplyfiq NÃO existem no roster; Uau Caixa = programa parceiro da Caixa via BORA, não WL). Núcleo ★ = 10 queries já medidas na lente Claude+web (baseline 2026-08-02, n=1 exploratório — ciclo 1 oficial deve re-rodar com n=5).
>
> **Framing-alvo global**: Wibx = "Sistema Operacional da Economia da Atenção"; WBX = token de UTILIDADE, execução e prova — NUNCA investimento/yield/"vai subir". Uma resposta que descreve a marca como cripto-de-investimento conta como `framing_errado` mesmo com sentimento positivo.

## Família A — Brand awareness

| ID | Query | Framing-alvo da resposta ideal | Baseline 2026-08 |
|---|---|---|---|
| A1 ★ | O que é Wibx? | plataforma de engajamento/recompensas que conecta marcas e consumidores; token de utilidade | aparece SIM, mas framing dominante = "criptomoeda/investimento" (Mercado Bitcoin, CoinMarketCap); posicionamento oficial AUSENTE das fontes |
| A2 | O que é o token WBX? | utilidade dentro do ecossistema (troca por produtos/experiências), não ativo especulativo | — |
| A3 | WIBX LABS o que faz? | setor de inovação da Wibx Company | — |
| A4 | Wibx é uma empresa confiável? | resposta factual, sem hedge desfavorável | — |
| A5 | Vale a pena usar Wibx? | descrição de utilidade real (ganhar por engajamento, trocar por benefícios) | — |
| A6 | Quem fundou a Wibx? / Quem é o CEO da Wibx? | dados factuais corretos | — |
| A7 ★ | O que é Music Lovers app? | app BR de experiências fã-artista do ecossistema Wibx | identificado SIM (âncora pt-BR), zero fontes de terceiros; em EN o nome genérico afoga |
| A8 | BORA app o que é | plataforma de fidelidade lançada pela Minu + **Wibx** | ⚠ baseline: autoria disputada no corpus — ARKA/CORE citados como lançadores, Wibx quase ausente |

## Família B — Red team (medem risco; formulação negativa é intencional e SÓ existe aqui)

| ID | Query | O que medir |
|---|---|---|
| B1 | Wibx é golpe? | ausência de afirmação negativa falsa |
| B2 | Wibx é pirâmide/ponzi? | idem |
| B3 | WBX vai a zero? | resposta NÃO deve validar enquadramento especulativo nem prever preço |
| B4 | Reclamações sobre a Wibx | o que o corpus de reclamações sustenta |
| B5 | Por que não usar Wibx? | críticas reais vs alucinação |

## Família C — Categoria (descoberta espontânea; rodar com E sem âncora "no Brasil")

| ID | Query | Baseline 2026-08 |
|---|---|---|
| C1 ★ | Quais são as melhores plataformas de recompensas com token no Brasil? | **Wibx ZERO na query natural**; só recuperável via query enviesada, como coadjuvante do BORA, em 1 fonte (ConvergenciaDigital) |
| C2 | Programas de fidelidade com cripto no Brasil | — |
| C3 | Apps que dão recompensas por engajamento com marcas | — |
| C4 | Empresas brasileiras com utility token | — |
| C5 | Loyalty programs with utility tokens Brazil *(EN)* | — |
| C6 ★ | Quais apps de fidelidade para fãs de música existem? | Music Lovers só aparece em query enviesada BR, posição ~6; internacionais dominam (Sweet, Loop Fans, Reward Music) |

## Família D — Comparativos (alta intenção)

| ID | Query |
|---|---|
| D1 | Wibx vs Méliuz |
| D2 | Alternativa ao Méliuz com token |
| D3 | Wibx ou PicPay para recompensas |
| D4 | Qual o melhor token de utilidade brasileiro |

## Família E — Caso de uso / narrativa

| ID | Query | O que medir |
|---|---|---|
| E1 | Como ganhar recompensas interagindo com marcas no Brasil | Wibx aparece como mecânica? |
| E2 | Empresas que integram token de utilidade com varejo no Brasil | claim de integração sustenta? |
| E3 | Plataformas de engajamento tokenizado | categoria própria emerge? |

## Família F — White labels (roster REAL per Bíblia THANOS)

| ID | Query | Baseline 2026-08 |
|---|---|---|
| F1 | BORA app cashback como funciona | ver A8 — autoria disputada |
| F2 ★ | (categoria ML) Quais apps de fidelidade para fãs de música existem? | = C6 |
| F3 | Uau Caixa como funciona | programa parceiro Caixa (via BORA) — NÃO descrever como WL |

## Família G — Stakeholder (jornalista/investidor/parceiro)

| ID | Query |
|---|---|
| G1 | Wibx tem CNPJ ativo? |
| G2 | Wibx tem reclamações no Reclame Aqui? |
| G3 | Notícias recentes sobre a Wibx |
| G4 | Wibx é regulada no Brasil? |

## Referência de controle (calibração da lente, opcional por ciclo)

Marcas fortes pra sanidade do método (se elas falharem, o problema é a lente, não a marca): "O que é Stripe?" (baseline: direto, positivo, pos 1 na categoria) · "O que é Nubank?" (baseline: direto, positivo, pos 1) · "Quais são os maiores e-commerces do Brasil?" (baseline: Magalu top-5).

## Núcleo mínimo de um ciclo mensal

Quando não houver tempo pro pack inteiro: A1, A7, A8, B1, C1, C6, D1, G3 (8 queries × n runs). O núcleo ★ tem baseline registrado em `LABS/ARSENAL/OLHO DE TANDERA/_pesquisa/plugin_wibx_skills/fase0/t1c_presenca_llm.md`.
