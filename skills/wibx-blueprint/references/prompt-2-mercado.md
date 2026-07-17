# PROMPT 2: MERCADO E CUSTOS (benchmark vs WiBX)

Output: `blueprints/[EMPRESA_ALVO]/MERCADO_[EMPRESA_ALVO].md`

Leia `DIAGNOSTICO_[EMPRESA_ALVO].md`. Agora faça o deep research de mercado e a prova de
economia, que é o argumento financeiro central do documento.

Pense passo a passo e produza, em markdown:

## 1. Sumário do gasto de mídia do setor

- Tamanho do investimento em mídia digital BR e do setor `[SETOR]`, com fonte e ano
- Desperdício de verba (impressão sem atenção), com fonte
- Onde o `[SETOR]` está na curva de CPM (caro/barato, regulado/livre)

## 2. Tabela de benchmarking: custo por métrica (mercado vs WiBX)

- Colunas: MÉTRICA, MERCADO (faixa + fonte + ano), WiBX, REDUÇÃO, CONFIANÇA
- Métricas: lead/cadastro, clique em link, pesquisa respondida, view (YouTube/Reels/TikTok),
  like, compartilhamento DM, download de app
- Preço WiBX vem da planilha de precificação obtida na Fase 0 via Notion. TODAS as 7 linhas
  precisam de preço WiBX, não só clique e lead. Se a Fase 0 trouxe a planilha completa, usar.
  Linha sem preço na fonte: marcar GAP no artefato, mas nunca deixar 5 de 7 linhas vazias no
  doc final. Precificação incompleta é bloqueador de qualidade, sinalizar no report de chat.
- Toda redução % tem os dois lados reais: benchmark de mercado com fonte E preço WiBX
- Marcar confiança (Alta/Média/Baixa) e sinalizar proxies (no artefato; no corpo Notion,
  colapsar em nota de metodologia, ver regras-globais voz)

## 3. Custo de mídia por vertical (WiBX flat, redução variável)

- Uma linha por vertical em que o cliente atua
- Coluna CPC de mercado (com fonte e ano) x WiBX flat x redução %
- A leitura estratégica: preço WiBX é flat, o de mercado não. A redução é maior nas verticais
  mais caras e mais reguladas (que costumam ser o core do cliente)

## 4. Efeito regulatório no custo de mídia (se aplicável)

- Como a regulação do setor (ex: ANVISA, BACEN, CVM) encarece ou restringe a mídia paga
  tradicional
- Como o canal proprietário de engajamento verificado (WBX) contorna a restrição e vira
  alavanca financeira, não só jurídica

## 5. Casos reais já executados (prova, não promessa)

- Tabela OBRIGATÓRIA com números: cliente/campanha, volume, custo WiBX, custo mercado
  equivalente, economia %. Esta é a prova mais forte do doc para board, não pode ir vazia.
- Usar os cases WiBX reais (Sebrae, Americanas, Banco Pan, e outros da página de cases obtida
  na Fase 0), com os números reais de volume e economia.
- Se a Fase 0 não trouxe os números dos cases: NÃO shipar tabela vazia com "em validação".
  Reportar no chat como bloqueador de alta prioridade e sinalizar que o doc precisa da página
  de cases antes de ir a board.

## 6. Fechamento "o que fura no board" (resposta ao CFO)

- Por que cada percentual é conservador e defensável
- A única variável em aberto (volume de verba do cliente, que o próprio cliente fecha)

Regras: todo número com fonte e ano via web_search, conversão cambial explicitada, sem
travessão, listas em bullet. Seção `## GAPs` ao final do arquivo.
