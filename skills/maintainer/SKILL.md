---
name: maintainer
description: >-
  Faz o papel de mantenedor dos repositórios da org Wibx-LABS (org fixa, nunca outra) numa
  varredura determinística: lê as PRs abertas dos repos configurados via gh, classifica cada uma (verde, CI pendente, conflito, CI vermelho,
  segurar), mergeia sozinho só o que é seguro, e comenta na PR instruindo quem a abriu (humano
  ou agente) sobre o próximo passo. Uma passada por invocação; persistência vem do /loop nativo.
  Use quando o usuário pedir para vigiar, cuidar, manter ou zelar por repos e PRs, quando houver
  fila de PRs de várias instâncias de agente conflitando entre si, ou quando pedir merge
  automático do que estiver verde. Dispara em "mantém esses repos", "cuida das minhas PRs",
  "/maintainer", "vigia o repo X", "resolve essa fila de PR", "mergeia o que tiver verde".
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
  - AskUserQuestion
---

# Maintainer

Varredura de mantenedor sobre PRs abertas em vários repos. Uma invocação = uma passada completa
(coletar, classificar, agir, reportar). Não fica em loop sozinho: quem repete é o `/loop`.

O problema que isso resolve: várias instâncias de agente abrindo PR em branches diferentes do
mesmo repo. Elas conflitam entre si, o CI quebra sem ninguém olhar, e merge na ordem errada
gera mais conflito. O maintainer mergeia na ordem certa e diz a cada PR travada o que fazer.

## Argumentos

| Arg | Efeito |
|-----|--------|
| _(nenhum)_ | Confirma a lista de repos, depois varre |
| `dry` | Classifica e reporta. Zero merge, zero comentário. **Use assim na primeira vez** |
| `go` | Pula a confirmação. Forma usada dentro do loop |
| `<repo>` | Varre só esse repo da org, ignora a config. Nome curto, sem `owner/` |

Combináveis: `/maintainer dry wibx-skills`.

Modo contínuo: `/loop 10m /maintainer go`.

## Org fixa

**`Wibx-LABS`. Hardcoded.** Todo slug é `Wibx-LABS/<repo>`, montado pelo skill, nunca digitado.

Se o argumento vier com `owner/` (ex. `outra-org/repo`), aceitar **apenas** se o owner for
`Wibx-LABS` (comparação case-insensitive, slug de GitHub não diferencia caixa). Qualquer outro
owner: recusar a passada inteira com `Fora da org Wibx-LABS: <slug>. Nada foi feito.` e parar.
Mesma regra para entradas da config — slug fora da org é ignorado e reportado, não varrido.

Este skill mergeia e comenta sozinho. A trava de org é o que garante que ele nunca faça isso
num repo de terceiro por typo ou config velha.

## Precondição

```bash
gh auth status
```

Falhou, para e diz exatamente o que falta. Não tenta contornar.

## Config

`~/.claude/maintainer/repos.json`:

```json
{ "repos": [ { "repo": "wibx-skills", "merge": "squash" } ] }
```

`repo` é o nome curto dentro de `Wibx-LABS`. `merge` ∈ `squash` | `merge` | `rebase`. Só esses
dois campos por repo.

Se o arquivo não existe, criar com `repos: []` e perguntar quais entrar, sugerindo os de:

```bash
gh repo list Wibx-LABS --limit 50 --no-archived --json name --jq '.[].name'
```

Se existe, mostrar a lista e deixar editar/adicionar via `AskUserQuestion` — **exceto** com o
arg `go`, que não pergunta nada.

Com um `<repo>` no argumento, a config é ignorada e o método de merge é `squash`.

## Passada, por repo

### 1. Coletar

```bash
gh pr list --repo <slug> --state open --limit 50 \
  --json number,title,author,isDraft,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup,additions,deletions,changedFiles,files,headRefName,headRefOid,updatedAt
```

Se `files` não vier no payload, buscar por PR: `gh pr view <n> --repo <slug> --json files`.

Zero PRs abertas: imprime `<slug>: nada aberto.` e passa para o próximo repo.

### 2. Classificar

Cada PR cai em **uma** faixa. Primeira condição que casar, nesta ordem:

| Faixa | Condição | Ação |
|-------|----------|------|
| `HOLD` | draft, ou `reviewDecision == CHANGES_REQUESTED`, ou `additions > 1000` **e não é PR de sync**, ou `statusCheckRollup` vazio/`null` | só relatório |
| `CONFLICT` | `mergeable == CONFLICTING` | comentário de rebase |
| `CI_RED` | algum check em `FAILURE` ou `ERROR` | comentário com job + causa |
| `WAIT` | algum check `PENDING`/`IN_PROGRESS`, ou `mergeable == UNKNOWN` | só relatório |
| `MERGE` | `mergeable == MERGEABLE` e **todos** os checks verdes | mergeia |

`statusCheckRollup` vazio ou `null` = repo sem CI configurado, ou PR que não disparou nenhum
workflow. Nos dois casos ninguém verificou nada, então **nunca auto-mergeia**: cai em `HOLD`,
sai no relatório marcada `sem CI` e entra em **Aguardando você**. Merge disso é decisão sua.

**PR de sync** = título começa com `chore(sync):` e a branch casa `sync/upstream-*`. O teto de
1000 linhas não se aplica a ela: o diff é código upstream já revisado lá fora, e quem a valida é
o `devkit/fork-gate`, não o tamanho. Sync do graphify passa de 2000 linhas rotineiramente — sob o
teto ela cai em `HOLD` toda passada e o repo nunca fecha o ciclo sozinho. As outras condições de
`HOLD` continuam valendo normalmente para ela, inclusive a de CI ausente.

### 3. Ordem de merge e cascata de conflito

É aqui que está o valor. Merge na ordem errada é o que cria a fila de conflito.

1. Ordenar a faixa `MERGE` por `additions` crescente. A menor entra primeiro.
2. **Sobreposição:** se duas PRs da faixa `MERGE` compartilham mais de 50% dos arquivos, só a
   menor mergeia nesta passada. A outra sai da faixa `MERGE`, vira `CONFLICT` e recebe o
   comentário de overlap citando a PR que está entrando.
3. Mergear **uma por vez**:
   ```bash
   gh pr merge <n> --repo <slug> --<merge> --delete-branch
   ```
4. Depois de **cada** merge, refazer o `gh pr list` do passo 1 para aquele repo e reclassificar
   o que sobrou. O GitHub leva alguns segundos para recalcular: `mergeable` volta `UNKNOWN`, a
   PR cai em `WAIT` e resolve na próxima passada. **Não fazer polling.** As que viraram
   `CONFLICTING` recebem o comentário de rebase nomeando a PR que acabou de entrar.

### 4. Comentar

```bash
gh pr comment <n> --repo <slug> --body-file - <<'EOF'
...
EOF
```

Inglês, direto, endereçado a quem abriu a PR — humano ou agente. Diz o que bloqueia, dá o
comando exato, uma linha de contexto. Sem elogio genérico, sem em dash, sem soar bot.

**Conflito depois de um merge:**
```
@<author> this branch conflicts with `<base>` now that #<merged> landed (it touched <file>).

Rebase and force-push:

    git fetch origin && git rebase origin/<base>
    # resolve, then
    git push --force-with-lease

Nothing else is blocking this one.

<!-- maintainer:CONFLICT:<headRefOid> -->
```

**Conflito sem merge recente:** mesma coisa, sem a cláusula do `#<merged>`.

**Overlap (segurada de propósito):**
```
@<author> holding this one for a moment. #<other> touches <N> of the same files and is smaller,
so it goes in first. Once it lands, rebase on `<base>` and this should merge clean.

<!-- maintainer:CONFLICT:<headRefOid> -->
```

**CI vermelho:**
```
@<author> `<job>` is failing on <sha-curto>:

    <2 a 5 linhas decisivas do log, nunca o log inteiro>

Everything else is green. Fix that and this merges on the next sweep.

<!-- maintainer:CI_RED:<headRefOid> -->
```

Puxar a causa com `gh run view <run-id> --repo <slug> --log-failed | tail -40` e citar só a
linha decisiva. Se não der para extrair, deixa só o nome do job e o link do run.

### 5. Anti-spam

Este skill roda a cada 10 minutos. Sem dedupe ele vira spam na terceira passada.

Todo comentário termina com o marcador oculto `<!-- maintainer:<faixa>:<headRefOid> -->`.
Antes de postar:

```bash
gh pr view <n> --repo <slug> --json comments \
  --jq '[.comments[].body | scan("<!-- maintainer:[^>]*-->")] | join(" ")'
```

Já existe comentário com a **mesma faixa e o mesmo SHA**: não posta. Push novo = SHA novo =
comenta de novo, porque o estado mudou. Zero arquivo de estado local.

## Relatório

Uma seção por repo, em PT-BR:

```
## <slug> — <N> PRs abertas

| PR | Autor | Tamanho | Faixa | Ação |
|----|-------|---------|-------|------|
| #12 | @kvag0 | +40/-3, 2 arq | MERGE | mergeada ✓ |
| #14 | @colega | +210/-8, 6 arq | CONFLICT | comentada (rebase) |
| #15 | @kvag0 | +90/-1, 3 arq | WAIT | CI rodando |

Mergeadas: 1 | Comentadas: 1 | Aguardando CI: 1 | Paradas: 0
```

Tamanho: `+<add>/-<del>, <N> arq`.

Itens que precisam de você (PR acima de 1000 linhas que não seja de sync, PR sem nenhum CI
configurado, PR com `CHANGES_REQUESTED` parada há mais de 7 dias) entram numa lista final
**Aguardando você**, com o motivo em uma linha.

Em modo `dry`, a coluna Ação mostra o que *seria* feito: `mergearia`, `comentaria (rebase)`.

## Guardas

Nada aqui é simplificável.

- **Nunca tocar em repo fora de `Wibx-LABS`.** Nem ler, nem comentar, nem mergear. Slug de fora
  aborta a passada.
- Nunca mergear com `mergeable != MERGEABLE`. Nunca mergear draft. Nunca passar por cima de
  `CHANGES_REQUESTED`. Nunca mergear PR sem nenhum check verde — ausência de CI não é sinal
  verde, é ausência de sinal.
- Nunca fazer rebase, force-push ou commit na branch de outro. O maintainer comenta, quem
  resolve é o dono da branch.
- Nunca fechar PR. Duplicata suspeita entra em **Aguardando você**.
- `gh pr merge` que falhar (branch protection, review obrigatória, merge queue): reportar o erro
  exato e seguir para a próxima PR. Não tentar contornar, não trocar o método de merge.
- **Nunca chamar `AskUserQuestion` no meio da varredura.** Isso trava o `/loop`. Decisão pendente
  vai para **Aguardando você** e reaparece na próxima passada. No máximo uma `AskUserQuestion`
  no fim, e só fora do modo `go`.
- Em modo `dry`: nenhum `gh pr merge`, nenhum `gh pr comment`. Só leitura.
