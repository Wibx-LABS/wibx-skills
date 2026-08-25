---
name: trim-cot-leakage
description: Use when auditing or fixing prose that reads like a leaked reasoning transcript — dead design-session citations, change narration such as "used to" or "no longer", stack or review vantage ("a later PR", "rejected in review"), reviewer-addressed justifications, control-flow narration, or hedged planning residue in comments, docs, skills, or memories. Also for requests like "clean up this doc", "does this read like a transcript", "audit my comments".
---

# Trimming Chain-of-Thought Leakage

Chain-of-thought leakage is prose whose vantage is the authoring session rather than the repository: it cites artifacts only that session could see, narrates the change instead of the state, or argues with a reviewer who has left.

**The fix is never deletion alone when a passage carries factual clauses.** Restate each so it stands at HEAD, then delete the transcript around it. A passage carrying no fact — an audit code, control-flow narration — is deleted outright.

## The one test

For every suspect passage ask: **could a reader at HEAD, with no access to any session transcript, PR thread, or uncommitted draft, resolve every reference and verify every claim?**

If no, restate the surviving facts from the repository's vantage and delete the rest. If yes, it is not leakage, however historical it sounds.

Resolvability only clears this bar. On current-state surfaces — READMEs, code comments, skill instructions — a *resolvable* change story is still change narration, and class 3 below routes it to its proper home.

## Taxonomy

1. **Dead design-session citations** — `(decision 7)`, `(audit C2)`, `plan §1.4`, phase labels (`T4`, `W3`). If the decision has a committed owner, cite it by path. Otherwise delete the citation and restate its factual clause so it stands alone.
2. **Stack and PR vantage** — "this PR adds", "a later PR", "the previous commit", "no item anterior". State the shipped mechanism or the extension point. Deferred work becomes a TODO marker or an issue reference.
3. **Change narration and version stamps** — "used to", "no longer", "previously", "antes era", "costumava", "the old X". State present behaviour. A fixed regression becomes a **counterfactual present** — "without X, Y happens" — never repository history.
4. **Review choreography** — "rejected in review", "the reviewer confirmed", "rejeitado na review", draft ordinals. Keep the surviving decision as plain fact; delete who said it when.
5. **Reviewer-addressed justification** — "the cast is safe — it simply…", "this is correct because…". A comment arguing its own correctness addresses a reviewer, not a maintainer. State the invariant that makes the code safe, or delete it if the code shows it.
6. **Restatement and derivation transcripts** — control-flow narration ("first we X, then we Y"), test walkthroughs, proofs of obvious branches. Delete; keep only a non-obvious contract.
7. **Hedges and planning residue** — "probably fine for now", "should be enough". Promote to `TODO`/`FIXME` or restate as the actual bound.
8. **Authoring-language slips** — untranslated fragments in prose whose language is otherwise consistent. Translate or delete.

## What is NOT leakage

Unaided citation-hunting fails in both directions, deleting durable references while keeping dead ones. These are keeps:

- **Issue and PR references** — `#1470`, `TODO(name):` resolve at HEAD. Keep them anywhere.
- **Merged-PR citations inside decision records and postmortems** — sanctioned evidence for a change story in its proper home.
- **Suppression justifications** — `# noqa: … -- reason`, `#[allow(dead_code)] // reason`, empty-catch explanations. Required prose. Fix a false reason; never delete it.
- **Counterfactual-present regression pins** — "without X, Y happens", "a naive X would…".
- **Measured bounds** — "(measured: 22.45s without the index, 0.068s with)". The provenance word *measured* is load-bearing.
- **Runtime old/new states** — "the old connection drains before the new one accepts" is lifecycle, not history.
- **Epistemic status markers** — "not verified", "hypothesis", "does not reproduce", "assumed". **Never trim these.** Cutting a hedge that marks what was actually checked turns a guess into a claim, which is the one edit that costs more than it saves.
- **Section references into committed documents** — `compliance_wbx.md §10` resolves at HEAD. The §-ban covers uncommitted drafts.
- **Project voice** — "we" as project voice; an Alternatives-considered section.

## Workflow

1. **Require an explicit scope.** A file, a directory, a diff. Never "the whole repo".
2. **Audit read-only first.** Grep the batteries in [references/examples.md](references/examples.md), then judge every hit semantically. The patterns are probes, not the definition — also read the densest prose in scope without a pattern in hand.
3. **Fix owner-first.** Generated output → fix the generator. A bilingual pair → update both sides. Model-visible strings → wording is behaviour; flag for a test-backed change rather than silently rewording.
4. **Before deleting anything, enumerate the passage's propositions** and check you are not flipping an obligation into an endorsement, promoting a hypothesis to a shipped feature, deleting a true fact, or dropping provenance.
5. **Verify.** Re-run the batteries expecting only sanctioned keeps, and confirm every remaining citation resolves at HEAD.
