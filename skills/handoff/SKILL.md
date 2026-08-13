---
name: handoff
description: |
  Gera um documento de HANDOFF de sessão — o estado vivo do trabalho salvo num lugar durável
  pra outra sessão (ou você depois de um /clear) retomar sem perder nada. Use SEMPRE que a
  conversa vai acabar ou trocar de dono: "faz um handoff", "/handoff", "vou limpar a conversa",
  "tô batendo o limite de contexto", "passa o bastão", "documenta onde paramos pra continuar
  amanhã", "salva o estado pra outra sessão", "preciso pausar isso e retomar depois", "resume
  isso pra eu abrir noutra janela". Diferente de um resumo: captura o estado VIVO (branch, PRs,
  processos em background, servidores, cwd, arquivos temporários), o PRÓXIMO PASSO com a receita
  exata pra rodar, e as pegadinhas que custaram tempo — e grava num lugar que a sessão nova acha
  (não no scratchpad, que morre com a sessão).
compatibility: Qualquer harness. Melhor aproveitado onde há auto-memória (deixa um ponteiro) e git/gh (captura branch/PRs).
---

# Handoff

O handoff existe porque contexto acaba e sessões morrem. Um bom handoff faz a próxima sessão
retomar em minutos, sem re-descobrir nada. Um handoff ruim é um resumo bonito que esquece a
parte que importa: o que estava RODANDO, onde os arquivos VIVEM, e qual era o PRÓXIMO passo.

A regra de ouro: **capture, não chute.** O estado vivo vem de comandos, não da sua memória da
conversa. Rode os comandos, cole a saída real. Um handoff que diz "acho que a branch é X" e
erra faz a próxima sessão perder mais tempo do que se não existisse.

## O processo (4 passos, nesta ordem)

### 1. Capture o estado VIVO (rodando comandos, não de memória)

O que a próxima sessão precisa saber pra não tropeçar. Rode o que se aplicar ao trabalho:

- **Git**: `git branch --show-current`, `git status --short` (tem coisa não commitada?), `git log --oneline -5`.
- **PRs/issues** (se houver repo remoto): `gh pr list --state open --json number,title,baseRefName --jq '...'` — quais abertas, contra qual base, o que já mergeou.
- **Processos em background**: servidores, workflows, jobs longos que você subiu. Estão vivos? Vão morrer com a sessão? Como re-subir? (porta, comando, env). Ex.: `lsof -ti :<porta>`, `docker compose ps`.
- **cwd e paths temporários**: onde estão os arquivos de trabalho que NÃO estão no git (scratchpad, /tmp, artefatos gerados). **Atenção: o scratchpad é por-sessão — a sessão nova tem um path diferente e NÃO acha esses arquivos.** Diga como regenerá-los.
- **Serviços externos**: banco/compose no ar? credenciais/env carregados de onde?

Não invente. Se um comando surpreende, é a razão de o handoff existir — registre o real.

### 2. Escolha um lugar DURÁVEL e deixe um ponteiro

O scratchpad e o /tmp da sessão **morrem** quando a conversa é limpa. A sessão nova começa
limpa e não sabe que o handoff existe. Então:

- **Grave o doc num lugar que sobrevive**: um `HANDOFF.md` no diretório de planos do harness, ou
  na raiz do projeto (se for aceitável commitar/gitignorar), ou num diretório out-of-band estável
  do projeto. Evite o scratchpad da sessão pro arquivo final.
- **Deixe um PONTEIRO onde a sessão nova OLHA primeiro.** Se o harness tem auto-memória (um
  índice carregado no início de toda sessão), acrescente uma linha apontando pro HANDOFF.md.
  Sem ponteiro, o doc perfeito fica invisível. Este é o passo que quase todo mundo esquece.

### 3. Escreva o doc — use este template

Preencha só as seções que têm conteúdo real; corte as vazias. Seja concreto (paths absolutos,
comandos que rodam, nomes de branch/PR exatos).

```markdown
# <PROJETO> — HANDOFF (<data>, fim da sessão)

Estado vivo pra retomar numa sessão nova. [aponte pro plano/memória/docs relevantes]

## Onde tudo está
- Repo / diretório de trabalho, package/subdir principal.
- Branch atual (+ se tem coisa não commitada). O que já mergeou vs o que está aberto.
- Arquivos fora do git (schema pack, artefatos, config out-of-band) e onde vivem / backup.
- Serviços: banco/compose no ar? como sobe? env carregado de onde?

## O que foi feito (commitado / entregue)
- Fase por fase ou tarefa por tarefa. Curto, com o path do que mudou.

## Estado atual / veredito (se pediram um)
- Onde o trabalho está de verdade, com a ressalva honesta (o que NÃO está provado).

## PRÓXIMO PASSO
- O que fazer a seguir, e a RECEITA EXATA pra rodar (comandos, env, paths). Se depende de
  regenerar algo do scratchpad morto, os comandos pra regenerar.

## GOTCHAS que custaram tempo (não repetir)
- As armadilhas concretas: ferramenta que mascara erro, cwd que persiste, índice que não cobre
  X, flag que precisa estar presente, ordem que importa. Isto é o ouro do handoff.

## Regras duras que não mudam
- Invariantes de governança/segurança que a sessão nova precisa respeitar de cara.
```

### 4. Confirme ao usuário

Diga onde gravou (os dois lugares: o doc + o ponteiro), e uma frase do que a sessão nova
faz primeiro. Curto. O usuário vai limpar a conversa — não encha.

## O que faz um handoff BOM (theory of mind)

Pense na próxima sessão como um colega competente que chega sem nenhum contexto, com o
terminal aberto na sua frente. Ele não sabe o codinome que você inventou, não viu o processo,
não sabe qual servidor está no ar. As três coisas que ele mais precisa, e que resumos comuns
mais esquecem:

1. **O estado que só existe em runtime** — o processo em background, o arquivo no scratchpad, a
   branch não-mergeada. Some quando a sessão morre; o handoff é a única cópia.
2. **O próximo passo executável** — não "continuar o teste", mas o comando exato, com env e
   paths, que dá o próximo resultado. Se envolve regenerar algo efêmero, a receita de regenerar.
3. **As pegadinhas** — cada armadilha que te custou tempo custa o mesmo tempo pra próxima sessão
   se não estiver escrita. "A ferramenta X mascara o erro real; use Y." vale mais que um parágrafo
   de arquitetura que o código já conta.

O que NÃO precisa: re-explicar o que o código/git/docs já registram. O handoff é o que se perde,
não o que já está salvo. Se está no README, aponte pro README; não copie.

## Distribuição (repo wibx-skills)

Skill nova em `skills/handoff/`. Pra publicar no marketplace interno, acrescente `handoff` à
lista de skills na descrição do plugin `wibx-skills` em `.claude-plugin/marketplace.json`, e
distribua com o fluxo do repo (`scripts/skill_management.py --sync` / `skill-management --sync`).
