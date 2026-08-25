# Recall batteries and calibration

Patterns are probes, not definitions. Every hit needs a semantic judgement.

## Batteries

```bash
# class 3 — change narration (EN + PT)
grep -rniE '\b(used to|no longer|previously|formerly|antes era|costumava|foi movido|renomeado)\b' <scope>

# class 2 — stack / PR vantage
grep -rniE '\b(this PR|a later PR|the previous commit|in this stack|no item anterior)\b' <scope>

# class 4 — review choreography
grep -rniE '(rejected in review|reviewer (said|confirmed|asked)|rejeitado na review|v[0-9]+ (of|desta) )' <scope>

# class 1 — dead session citations
grep -rnoE '\((decision|audit|item) [0-9A-Z-]+\)|§[0-9]' <scope>

# class 7 — hedges
grep -rniE '\b(probably fine|should be enough|por ora|talvez seja)\b' <scope>
```

## Calibration — hits that are KEEPS

| Hit | Verdict |
|---|---|
| `used to compare what git returned` | keep — *employed to*, not *formerly* |
| `compliance_wbx.md §10` | keep — a committed document owning its numbering |
| `no longer matches CRED_PATTERN` in a runtime failure message | keep — runtime state, not repository history |
| `#[allow(dead_code)] // no caller until the wiring lands` | keep — suppression justification, required |
| `measured 22.45s without the index, 0.068s with` | keep — measured bound, provenance load-bearing |
| `hypothesis, not confirmed` | **keep, always** — an epistemic marker; trimming it turns a guess into a claim |

## Calibration — hits that are LEAKAGE

| Hit | Rewrite |
|---|---|
| `// Regression: rtk used to separate records with "---END---"` | `// Without NUL separation, a commit body containing the marker splits one record into several.` |
| `// this PR moves the notice outside never_worse` | `// The notice sits outside never_worse: its baseline is already-capped output.` |
| `// rejected in review: we tried a wider regex first` | delete; keep the surviving rule only |
| `// first we filter, then we guard, then we append` | delete; the code shows it |

## Overcorrection traps

- Flipping an obligation into an endorsement ("must not" → "does not").
- Promoting a hypothesis to a shipped feature by deleting its hedge.
- Deleting a true fact because the sentence around it was narration.
- Dropping provenance — *measured*, *verified*, *reproduced* are not decoration.
