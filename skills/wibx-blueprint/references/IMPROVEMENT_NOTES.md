# Notas de melhoria: draft vs doc-casa Cimed

Comparação do smoke-test (`blueprints/CIMED/BLUEPRINT_CIMED.notion.md`) contra o doc real
autoral (Matheus Domm, Notion 39ecef37). Fonte para iterar a skill. Data: 2026-07-17.

## Veredito

Draft acerta esqueleto (template espelha a casa), ganha em sourcing (fonte+ano+câmbio,
coluna confiança) e financeiro atual (queda 2025). Perde em richness: cases, precificação
completa, produto-por-iniciativa, campanhas ativas, UAU Caixa, profundidade de
personalidades e matriz marca x rede.

## 2 causas-raiz

- **A) Fase 0 não puxou dados internos** (precificação, cases, catálogo de produtos com UAU
  Caixa) e caiu no fallback template de 2 linhas. Corrigir `config.md` com fallback rico fecha
  os 3 gaps de maior impacto de uma vez.
- **B) Montagem do prompt-3 achata em prosa** dados estruturados que o diagnóstico já capturou
  (matriz marca x rede, personalidades com quote). Fix: prompt-3 renderiza TABELA a partir dos
  artefatos, não re-resume.

## 12 melhorias acionáveis (ranqueadas, generalizáveis)

1. **Precificação completa no config como fallback**, não 2 linhas. Lista default: clique
   R$ 0,40, lead R$ 25, pesquisa R$ 1,50, view R$ 0,10 a 0,15, like R$ 0,08, DM R$ 0,50,
   download R$ 2,50. Arquivo: `config.md` + Fase 0. (Draft shipou 5 de 7 linhas vazias.)
2. **Tabela de cases como requisito duro, com fallback numérico no config**. Sebrae/
   Americanas/Banco Pan com volume, custo WiBX, custo mercado, economia %. Proibir tabela de
   cases vazia. Arquivo: `config.md`, `prompt-2-mercado.md` secao 5.
3. **Expandir catálogo de produtos WiBX no prompt-3 + forçar mapeamento por iniciativa**.
   Adicionar UAU Caixa (loyalty CAIXA), reforçar WBCS/TKN Driver/PTWAE/Seller Token Layer.
   Instrução: mapear produto NOMEADO a cada iniciativa (ex: Meu Carmed = Wallet API + TKN
   Driver). Arquivo: `prompt-3-cruzamento.md`.
4. **Pesquisar campanhas em curso do cliente e ancorar Frente 1 nelas por nome**. Novo alvo
   de research no diagnóstico: "ações/ativações agora" (promos, votações, licenciados, TV
   tie-ins). Arquivo: `prompt-1-diagnostico.md` (nova subsecao) + `prompt-3` frentes.
5. **Restaurar matriz marca x rede como tabela obrigatória** (parar de achatar em prosa dado
   que já existe no diagnóstico). Arquivo: `prompt-3-cruzamento.md` secao portfólio.
6. **Personalidades: 1 subsecao por pessoa com quote + nomear o decisor de entrada**
   ("Decisor natural da porta de entrada"). Capturar quotes no diagnóstico. Arquivo:
   `prompt-1-diagnostico.md` secao 4 + `prompt-3`.
7. **Codificar o mecanismo de receita "cada movimentação gera taxa" + o fecho de board
   "cliente não constrói nada, PLUGA em ativos já operando"** na tese invariante. Arquivo:
   `regras-globais.md` tese central + `prompt-3` modelo de negócio.
8. **Mermaid estilizado (classDef com paleta de cor) obrigatório** no diagrama de Times.
   Reusar tokens `wibx-brand`. Arquivo: `prompt-3-cruzamento.md` secao Times.
9. **Spans de cor no callout de capa + convenção 🔹 lead-in no corpo**. Capa: label em
   `<span color="yellow">`, tese em `<span color="blue">`, autor em `<span color="green">`.
   Arquivo: `regras-globais.md`, `prompt-3` abertura.
10. **Hyperlinkar fontes; mudar formato de retorno dos subagents para carregar URL**. Formato
    novo: `fato | [fonte](url) | ano`. Regra evidência exige link markdown na célula FONTE
    quando URL conhecida. Arquivo: `regras-globais.md` (bloco subagent) + Fases 1-2.
11. **Padronizar Notion craft**: tag `plain text` em toda fence de diagrama,
    `fit-page-width="true"` em tabelas largas, emoji por linha em tabelas de marca/vertical,
    ícone 🥷 em todo callout "o que fura no board". Arquivo: `prompt-3` + checklist em
    `regras-globais.md`.
12. **Preferir voz-casa confiante à voz-apêndice-de-pesquisa**. Colapsar coluna CONFIANÇA e
    flags de proxy numa nota de metodologia única por tabela; GAPs vão só pro report no chat,
    nunca pro corpo Notion. Rigor fica nos artefatos e no chat, não no slide de board. Arquivo:
    `regras-globais.md` (estilo), `prompt-3` (o que vai pro Notion vs chat).

## Onde o draft ganhou (preservar)

- Sourcing: fonte+ano em tudo, câmbio explícito e datado, coluna confiança, proxies
  sinalizados. Doc-casa é mais solto (números redondos sem fonte).
- Financeiro atual: draft tem a virada de 2025 (lucro -30%, Ebitda 16% vs 21%, caixa negativo,
  Fitch AA(bra), dívida 3,7x, ICMS-ST R$ 590 mi). Doc-casa lê 2024 otimista.
- Regulação por plataforma: draft detalha Meta/Google/TikTok BR; doc-casa é mais narrativo.

Conclusão de design: manter rigor de pesquisa nos artefatos intermediários e no report de
chat; deixar o corpo Notion na voz-casa assertiva e rica. Os dois não competem se o rigor
mora no lugar certo.
