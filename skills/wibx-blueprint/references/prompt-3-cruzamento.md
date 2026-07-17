# PROMPT 3: CRUZAMENTO DE OPORTUNIDADES + DOC FINAL

Output: página Notion em `[LINK_NOTION_DESTINO]`

Leia `DIAGNOSTICO_[EMPRESA_ALVO].md` e `MERCADO_[EMPRESA_ALVO].md`. Agora produza o documento
final no padrão WiBX Project Blueprint e escreva DENTRO da página Notion em
`[LINK_NOTION_DESTINO]` usando `notion-update-page`. NUNCA crie subpágina filha.

Antes de escrever, leia o spec de markdown enriquecido do Notion
(`notion://docs/enhanced-markdown-spec`) para acertar toggles, colgroup, callouts, plain text
e mermaid.

O cruzamento é o coração deste prompt: pegue cada dor do diagnóstico e cada dado de custo do
mercado e transforme em vetores de valor e frentes encadeadas.

## Estrutura obrigatória do documento, na ordem

### Abertura (callout de capa 🥷🏽)

- By: Matheus Domm (em `<span color="green">`)
- PROJETO [EMPRESA_ALVO] x WiBX + natureza da proposta
- NATUREZA, PÚBLICO, TESE CENTRAL, NÚCLEO ARGUMENTATIVO, COMO A WiBX GANHA (labels em
  `<span color="yellow">`; a frase-tese central em `<span color="blue">`)
- COMO A WiBX GANHA: explicitar o mecanismo de taxa por movimentação (ver regras-globais tese)
- Nota: "Este documento é a referência do projeto. Versões em PDF ou apresentação derivam
  dele."

### Tabela EMPRESAS x FUNÇÃO

- WIBX (tecnologia + operação), parceiros de [PARCEIROS_WIBX], cliente
- Só incluir CORE se estiver em [PARCEIROS_WIBX]

### 🎯 Sumário Executivo da Proposta

- A oportunidade em uma frase (callout azul)
- A régua da proposta: tabela resumida mercado vs WiBX com as métricas de maior impacto
  (mirar 5 a 6 linhas, não 2 a 3), puxada da fase 2
- Mapa de oportunidades (as frentes, um só ativo)

### 💊 Quem é a empresa (toggle)

Da fase 1: canais (tabela CANAL/LINK, colgroup 225/444, emoji por tipo), quem é, números,
decisores.

### 🏷️ Portfólio de marcas e objetivo de mídia (toggle)

Da fase 1. Incluir a tabela de marcas (emoji por linha) E a matriz marca x rede social como
TABELA (grid marca nas linhas, redes nas colunas, handle na célula). Não achatar a matriz em
prosa: o diagnóstico já capturou o grid, renderizar como grid.

### 🎙️ Personalidades (toggle)

Da fase 1, se aplicável. Uma subseção por pessoa-chave (👤 com audiência-faixa, conteúdo,
papel, e QUOTE quando houver), não uma tabela achatada. Incluir a nota estratégica de
founder/creator e nomear o "Decisor natural da porta de entrada" (usar 🔹 lead-in).

### 🎯 Os vetores de valor (toggle)

- Cada vetor: O QUÊ, DOR QUE RESOLVE (referenciando as dores numeradas), RESULTADO ESPERADO
  (métrica), POR QUE SÓ A WiBX ENTREGA
- Callout "o que fura no board" ao final

### 💰 Prova de economia (toggle)

As tabelas da fase 2 embutidas.

### 📟 One Page (toggle)

O que é, as frentes, o que resolve, como a WiBX ganha, frase final.

### 🧠 Conceito (toggle)

A virada de chave, o problema em blocos de dores, plain text da definição do projeto.

### 🧩 As frentes detalhadas (toggle)

Cada frente com tabela iniciativa/como o WBX entra e diagrama plain text de exemplo (fence com
tag ```plain text). Cada iniciativa mapeia um PRODUTO WiBX nomeado (ex: "Meu Carmed = WBX
Wallet API + TKN Driver"), não mecânica genérica. Ancorar as iniciativas nas campanhas em
curso do cliente levantadas na Fase 1 (nome próprio da ação), não em exemplos abstratos.

### 🎲 Sequenciamento e estratégia (toggle)

- Ordem das frentes com racional
- Matriz de fit dor por dor (dor, produto WiBX, esforço B/M/A, impacto B/M/A, prioridade)

### 💰 Modelo de negócio (toggle)

Como a WiBX ganha, loop econômico em plain text (fence ```plain text). Explicitar o mecanismo
de receita: a WiBX não vende software, ganha como sócia da plataforma e nas taxas de
movimentação do WBX (cada movimentação gera taxa). Ver regras-globais tese central.

### 🌐 Estratégia cross-channel WiBX Hub (toggle)

Bora (JV Minu + WiBX, nanoinfluencers, escala de usuários ativos/dia), Music Lovers, nuvem
MINU, e UAU Caixa (app de fidelidade da CAIXA sobre tecnologia WiBX, escala de programa
federal). Descrever o ativo com seus números reais quando conhecidos, não só o nome.

### 🛠️ O que vamos precisar desenvolver (toggle)

Componente, frente, status.

### 📅 Fases (toggle)

#, fase, entregável (bullets), responsável.

### ⚠️ Riscos e questões em aberto (toggle)

Risco, impacto (🔴🟡🟢), status/próximo passo + bloco compliance em plain text.

### 👥 Times (toggle)

Frente, responsável + mermaid ESTILIZADO do modelo operacional: `flowchart TD` com paleta
`classDef` por nível (reusar tokens da skill wibx-brand), nós com `class` atribuída. Flowchart
pelado sem cor é erro de acabamento.

### Rodapé

*Documento de Projeto [EMPRESA_ALVO] x WiBX • Conceito, Estratégia, Aplicação e
Desenvolvimento*

## Produtos WiBX a mapear no cruzamento

- WBX (token), WBCS Token Engine, WBX Wallet API, Seller Token Layer, TKN Driver, PTWAE
- Mecânicas: Indica+, Play, Clique & Responda, Circuito, Grupos VIP
- Ambientes do Hub: Bora e Music Lovers
- Distribuição de escala: UAU Caixa (app de fidelidade da CAIXA sobre tecnologia WiBX)
- Resgate: nuvem de benefícios MINU

Regra de mapeamento: cada iniciativa de frente cita um produto NOMEADO da lista acima, não
"mecânicas WBX" genérico. Se uma frente inteira puder plugar num ativo de escala já operando
(UAU Caixa, Bora), tratar isso como um vetor de valor próprio (o argumento "cliente não
constrói nada, pluga no que já existe" é o fecho de board mais forte).

Regras: português BR, sem travessão, listas em bullet dentro de célula, factual sem
bajulação, escrever DENTRO da página com update-page. Ao terminar, reportar no chat os GAPs
de research e canais não encontrados.
