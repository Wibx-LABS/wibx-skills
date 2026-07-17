# Config: fontes internas WiBX no Notion

URLs fixas consultadas na Fase 0 via notion-fetch. Editar aqui quando as páginas mudarem.

| Fonte | URL |
|---|---|
| Planilha de precificação WiBX | `PLACEHOLDER_URL_PRECIFICACAO` |
| Cases reais (Sebrae, Americanas, Banco Pan, ...) | `PLACEHOLDER_URL_CASES` |

## Schema esperado da precificação (7 linhas, todas com preço)

A tabela de benchmark do doc precisa das 7 métricas com preço WiBX. Puxar TODAS da planilha,
não só clique e lead. Linha faltando na fonte vira GAP no artefato e bloqueador no report.

- Lead/cadastro
- Clique em link
- Pesquisa respondida
- View (YouTube/Reels/TikTok)
- Like/engajamento
- Compartilhamento DM
- Download de app

## Schema esperado dos cases (tabela com números, obrigatória)

- Cliente/campanha
- Volume (ex: nº de leads, engajamentos, KYC)
- Custo WiBX (R$)
- Custo mercado equivalente (R$)
- Economia %

## Fallback

1. URL placeholder ou notion-fetch falhou: notion-search por "precificação WiBX" e
   "cases WiBX"; validar que a página encontrada é mesmo a fonte certa antes de usar.
2. Nada encontrado: usar os valores mínimos conhecidos abaixo, marcar as demais linhas como
   GAP, e reportar no chat como bloqueador de qualidade (precificação incompleta e cases sem
   número derrubam a força do doc para board).

## Valores mínimos conhecidos (fallback nível 2, só se o Notion falhar)

| Métrica | Preço WiBX |
|---|---|
| Clique em link | R$ 0,40 |
| Lead/cadastro | R$ 25,00 |

As demais 5 linhas de precificação e todos os números de cases vêm do Notion. Sem eles, o
doc sai incompleto por definição, sinalizar claramente.
