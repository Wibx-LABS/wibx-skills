# Catálogo de diagramas (100% da galeria diagram-design, 61 modelos)

Fonte: https://cathrynlavery.github.io/diagram-design/ (v2.6.33, MIT), cópia local em `gallery/original/`.
Versão na marca Wibx: gerada por `python3 scripts/brand_gallery.py <projeto>/diagramas` (nunca dentro da pasta da skill).
Cada modelo tem `example-<modelo>.html` (claro), `-dark.html` (escuro; use em deck escuro) e `-full.html` (editorial). Modelos marcados com ◐ só têm uma variante.
A gramática de cada tipo (orçamento de nós, conectores, legenda) está no próprio exemplo: leia o SVG `-dark` antes de adaptar. Regra geral: 5 a 9 nós por diagrama, 1 a 2 focais, grade de 4px.

## Como escolher (pergunta → modelo)

| O slide precisa mostrar... | Modelo |
|---|---|
| como um sistema funciona por dentro | architecture · high-level · deployment |
| o antes (processo atual, manual, com dor) | it-state |
| uma decisão com caminhos | flowchart |
| quem fala com quem, em ordem | sequence · sequence-oauth |
| quem faz o quê ao longo do tempo | swimlane · process · data-flow |
| estados e transições de uma coisa | state · state-lifecycle |
| um ciclo que se reforça | loop |
| onde estamos / roadmap | timeline · gantt |
| prioridade, posicionamento 2×2 | quadrant · quadrant-consultant · wardley |
| interseção de requisitos | venn |
| hierarquia / escopo | tree · org-chart · nested · layers · pyramid |
| números: comparação, evolução, composição | bar · line · waterfall · treemap · marimekko · sankey |
| distribuição / risco | scatter · bubble · beeswarm · ridgeline · heatmap |
| ranking e virada | bump · slopegraph · streamgraph |
| perfil multicritério | radar · polar |
| causa-raiz | fishbone |
| experiência do cliente | journey · story-map |
| trabalho em andamento | kanban |
| dados / modelo técnico | er · db-schema · uml-class · dependency · dp-security-matrix |
| plataforma de dados | datalake · medallion · dp-integration · high-level-vertical |
| regra passo a passo / segurança | policy-trace-animated · queue-animated · paved-road-animated |

## Receitas de animação (controller.js: `data-seq`, `.draw`, `.pop`, `.fade`)

- **R-FLUXO** (arquitetura, fluxos, processos): zonas `.fade` seq 0 → nós `.pop` na ordem do fluxo → conectores `.draw` com o mesmo seq do nó de destino (ponta aparece na chegada) → rótulos `.fade` → legenda por último. Opcional: pacotes de dados no caminho principal com `data-packet` em **todos** os conectores desse caminho (o controller segue o path real, inclusive cotovelos; lições A7).
- **R-SEQ** (sequência): atores e linhas de vida `.fade` seq 0 → cada mensagem `.draw` em seq crescente, de cima para baixo → fragmentos alt/opt `.fade` junto da 1ª mensagem interna.
- **R-HIER** (tree, org, pyramid, layers, nested): raiz/camada base primeiro, depois nível a nível (seq = profundidade); pirâmide de baixo para cima; nested de fora para dentro.
- **R-BARRA** (bar, waterfall, gantt, marimekko): eixos `.draw` seq 0 → barras com `scaleY` a partir da base (`transform-origin` na linha de base; use `.pop` com origem ajustada ou tween próprio) em stagger da esquerda para a direita; waterfall em sequência cumulativa; valores `.fade` ao fim de cada barra.
- **R-LINHA** (line, slopegraph, bump, ridgeline, streamgraph): eixos → cada série `.draw` (stroke) com seq por série, a focal por último → pontos `.pop` → rótulos.
- **R-PONTO** (scatter, bubble, beeswarm, heatmap, treemap): eixos/grade → pontos/células `.pop` em stagger (heatmap por linha; treemap do maior para o menor) → foco destacado por último.
- **R-RADIAL** (radar, polar, venn, loop): grade/círculos `.draw` → preenchimentos `.fade` → polígono/fatia focal `.pop` → rótulos. Loop: arcos no sentido horário + `.flow` contínuo.
- **R-FLUXO-VOLUME** (sankey): nós `.fade` → faixas reveladas da esquerda para a direita (clipPath animado ou opacidade em stagger por coluna) → faixa focal por último.
- **R-QUADRO** (quadrant, wardley, kanban, journey, story-map, fishbone, matrix): eixos/colunas → itens `.pop` por grupo → curva (journey) `.draw` → foco.
- **R-PASSO** (modelos *-animated): já têm controlador próprio (`data-motion-root`); no deck, use o ritmo `data-step` e mantenha 1 passo por clique se o apresentador precisar narrar.

Regras comuns: nada anima sem motivo (hierarquia, narrativa, estado); reduced-motion mostra o quadro final; setas com `marker-end` sempre via `.draw` (lições A2).

## Catálogo completo

### Sistemas e arquitetura
| Modelo | Use no deck para | Tipo | Anim. |
|---|---|---|---|
| architecture | componentes e conexões de um sistema | architecture | R-FLUXO |
| high-level | stack ponta a ponta com faixa de etapas (chevrons), cluster, barra de orquestração e identidade | high-level | R-FLUXO |
| high-level-vertical | mesmo, com faixa vertical de temas transversais (segurança, observabilidade) | high-level | R-FLUXO |
| datalake | arquitetura de data lake aberto | architecture | R-FLUXO |
| dp-integration | plataforma: fontes → núcleo → consumidores + camadas de serviço | dp-integration | R-FLUXO |
| deployment | onde o software roda: zonas, hosts, réplicas, portas | deployment | R-HIER |
| dependency | o que depende do quê (fan-in, ciclos) | dependency | R-FLUXO |
| it-state | cenário atual (antes), com gargalos e dores | it-state | R-FLUXO |
| medallion | camadas de dados por qualidade (bronze/prata/ouro) | medallion | R-HIER |
| layers | pilha de abstração, com camada focal | layers | R-HIER |
| nested | escopo/herança por contenção | nested | R-HIER |
| uml-class | domínio técnico (classes, herança, composição) | uml-class | R-FLUXO |

### Fluxo, processo e tempo
| Modelo | Use no deck para | Tipo | Anim. |
|---|---|---|---|
| flowchart | decisão com ramificações | flowchart | R-FLUXO |
| sequence | mensagens entre atores em ordem | sequence | R-SEQ |
| sequence-oauth | sequência com fragmento alt (sucesso x erro/retry) | sequence | R-SEQ |
| swimlane | processo entre áreas com handoffs | swimlane | R-FLUXO (colunas) |
| process | processo multiárea com passos numerados e tipos de dado | process | R-FLUXO |
| data-flow | quem faz o quê em cada etapa do pipeline | data-flow | R-FLUXO |
| state | máquina de estados | state | R-FLUXO |
| state-lifecycle | ciclo de vida com trilho principal, faixa de recuperação e fins | state | R-FLUXO |
| loop | ciclo que se reforça com hub de estado | loop | R-RADIAL |
| timeline | marcos no tempo | timeline | R-LINHA |
| gantt | plano/cronograma | gantt | R-BARRA |

### Estrutura e hierarquia
| Modelo | Use no deck para | Tipo | Anim. |
|---|---|---|---|
| tree | taxonomia / decomposição | tree | R-HIER |
| tree-block-decomposition | decomposição rastreável com IDs, entradas e saídas | tree | R-HIER |
| org-chart | responsabilidade, escalonamento, time | org-chart | R-HIER |
| pyramid | hierarquia ranqueada ou funil de conversão | pyramid | R-HIER |
| er | entidades e relacionamentos (visão de negócio) | er | R-FLUXO |
| db-schema | tabelas físicas, tipos, FKs | db-schema | R-FLUXO |

### Estratégia e posicionamento
| Modelo | Use no deck para | Tipo | Anim. |
|---|---|---|---|
| quadrant | matriz 2×2 (impacto × esforço) | quadrant | R-QUADRO |
| quadrant-consultant ◐ | matriz de cenários estilo consultoria | quadrant | R-QUADRO |
| venn | interseção de requisitos / sweet spot | venn | R-RADIAL |
| wardley | cadeia de valor × evolução (build/buy) | wardley | R-QUADRO |
| fishbone | causa-raiz por categoria | fishbone | R-QUADRO |
| journey | jornada do cliente com curva de sentimento | journey | R-QUADRO |
| story-map | backbone de narrativa com corte de release | story-map | R-QUADRO |
| kanban | trabalho em andamento com WIP | kanban | R-QUADRO |

### Dados e gráficos
| Modelo | Use no deck para | Tipo | Anim. |
|---|---|---|---|
| bar | comparação entre categorias | bar | R-BARRA |
| waterfall | ponte de valor (orçamento A → B) | waterfall | R-BARRA |
| marimekko | composição em duas dimensões (largura e altura) | bar | R-BARRA |
| line | tendência contínua | line | R-LINHA |
| slopegraph | antes × depois | line | R-LINHA |
| bump | mudança de ranking | line | R-LINHA |
| ridgeline | distribuições por série | line | R-LINHA |
| streamgraph | composição ao longo do tempo | line | R-LINHA |
| scatter | correlação de duas variáveis | scatter | R-PONTO |
| bubble | três variáveis (x, y, tamanho) | scatter | R-PONTO |
| beeswarm | distribuição de uma variável, ponto a ponto | scatter | R-PONTO |
| treemap | parte do todo por área | treemap | R-PONTO |
| heatmap | tabela cruzada com intensidade | heatmap | R-PONTO |
| radar | perfil multicritério (3 a 5 eixos) | radar | R-RADIAL |
| polar | uma série cíclica (horas, meses) | polar | R-RADIAL |
| sankey | volume que se divide e se junta | sankey | R-FLUXO-VOLUME |
| dp-security-matrix | permissões papel × componente | dp-security-matrix | R-PONTO |

### Padrões animados e importação
| Modelo | Use no deck para | Tipo | Anim. |
|---|---|---|---|
| policy-trace-animated ◐ | duas requisições avaliadas por regras, até a divergência | semantic: paired traces | R-PASSO |
| queue-animated ◐ | fila / gargalo de entrada | semantic: fan-in queue | R-PASSO |
| paved-road-animated ◐ | caminho seguro autorizado × tentativa bloqueada | semantic: secure paved road | R-PASSO |
| loop-terminal ◐ | loop em skin terminal (posts de dev tool; não usar com marca) | loop + terminal | R-RADIAL |
| import-drawio ◐ | redesenhar diagrama do draw.io na marca | import | R-FLUXO |
| import-mermaid ◐ | redesenhar Mermaid na marca | import | R-FLUXO |
| import-excalidraw ◐ | redesenhar Excalidraw na marca | import | R-FLUXO |

## Levar um modelo para o slide (passo a passo)

1. Gere a galeria na marca dentro do projeto: `python3 scripts/brand_gallery.py <projeto>/diagramas` (uma vez por projeto).
2. Abra o exemplo `-dark` gerado para ver a gramática do tipo (orçamento de nós, regras de conector).
3. Extraia com IDs prefixados: `python3 scripts/extract_svg.py <projeto>/diagramas/<exemplo> <prefixo> --anim`.
4. Remova o `<rect>` de fundo de tela cheia (o slide já tem fundo), adicione `class="dg"`, posicione no palco 1920×1080.
5. Troque o conteúdo pelos dados reais do cliente, nunca invente componente para preencher layout. Se o texto real for maior, redimensione a caixa (grid de 4px).
6. Ajuste `data-seq` à narrativa (receita acima) e `data-step` no `<section>`.
7. QA: `qa_static.py` (ids, paleta, a11y) + `qa_browser.js` (overflow, sobreposição) + capturas no meio e no fim da animação.
