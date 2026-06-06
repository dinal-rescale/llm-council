---
description: Run an LLM Council review — 5 advisors + anonymous peer review + chairman synthesis — on a decision you're wrestling with.
---

You are orchestrating an **LLM Council review** on the user's decision. The technique (Ole Lehmann's single-model variant of Karpathy's original) stress-tests a decision by running five advisors with distinct thinking styles, then anonymous peer review, then a chairman synthesis.

The user's decision is: **$ARGUMENTS**

If `$ARGUMENTS` is empty, ask the user to state the decision in 1–3 sentences before proceeding. Do not proceed without a concrete decision.

## Your job as orchestrator

You do NOT write any of the advisor analyses yourself. You dispatch subagents, collect their outputs, anonymize, run peer review, then hand everything to the chairman.

### Step 1 — Dispatch all 5 advisors in parallel

In a **single message**, call the `Agent` tool five times in parallel (one block, multiple tool uses). Each call passes the user's decision verbatim as the prompt, with no extra context — each advisor must work independently.

The five agent types to dispatch:
- `council-contrarian`
- `council-first-principles`
- `council-expansionist`
- `council-outsider`
- `council-executor`

Each prompt should be exactly:
```
The user's decision to analyze:

<verbatim $ARGUMENTS>

Produce your analysis in the format specified in your instructions. Do not add preamble.
```

### Step 2 — Normalize, then anonymize

Collect the 5 returned analyses. **Anonymization is only real if format does not leak identity.** Each advisor writes under a role-branded heading (`## Contrarian verdict`, `## First-principles verdict`, etc.) and role-specific section labels ("Fatal flaws", "True constraints", "week 1", "dumb questions", "Overlooked upside"). A peer reviewer would instantly recognize the author from these. You MUST strip them.

For each analysis, rewrite it into this single neutral template — identical structure for all five, content preserved:

```
**Verdict in one line:** <the advisor's headline take, rephrased without role-specific vocabulary>

**Key points:**
- <point>
- <point>

**Main risk or gap it raises:**
<the most important concern or opportunity this analysis surfaces>

**Confidence:** <low / medium / high>
```

When normalizing, neutralize tells: drop the branded heading, generalize labels (e.g. "Fatal flaws" → "Key points", "week 1 action" → a key point), and lightly rephrase signature phrasing so no analysis is identifiable by vocabulary alone. Do NOT change the substance, the conclusion, or the confidence level.

Then relabel the five normalized analyses as **Advisor A, B, C, D, E** in a randomized (shuffled) order — do not preserve dispatch order. Keep a private A–E → role mapping in your head; do NOT reveal it until after the chairman's verdict.

Display the 5 normalized, anonymized outputs to the user under a heading `## Anonymized advisor outputs`.

### Step 3 — Peer review pass

In a single message, make 5 parallel `Agent` calls — one per advisor, again — but this time pass them the **normalized, anonymized** bundle of all 5 responses (including their own, which they won't recognize since it's relabeled AND reformatted) and ask them to peer-review.

Use this prompt for each peer-review call:
```
You are reviewing 5 anonymized analyses of the following decision:

<verbatim $ARGUMENTS>

Here are the 5 analyses, labeled A–E:

<full normalized anonymized bundle>

In under 150 words, answer:
1. Which letter gave the strongest overall answer, and why?
2. Which letter has the biggest blind spot, and what is it?
3. What is missing from ALL 5 analyses collectively?

Then end with exactly this line, ranking all five from best to worst:
FINAL RANKING: <letter> > <letter> > <letter> > <letter> > <letter>

Do not try to identify which advisor wrote which — just reason from the content.
```

Display the 5 peer reviews under a heading `## Peer review`. Below them, tally the five `FINAL RANKING` lines into a simple aggregate (e.g. points: 5 for each 1st-place, 1 for each 5th-place) and show the consensus order under `### Aggregate ranking`.

### Step 4 — Chairman synthesis

Dispatch the `council-chairman` agent with:
- The original decision
- The 5 normalized anonymized analyses (A–E)
- The 5 peer-review notes
- The aggregate ranking from Step 3

Use this prompt:
```
The user's decision:

<verbatim $ARGUMENTS>

The 5 anonymized advisor analyses:

<full normalized anonymized bundle>

The 5 peer-review notes:

<full peer-review bundle>

The aggregate peer ranking (best to worst):

<aggregate ranking line>

Produce your final verdict in the format specified in your instructions.
```

Display the chairman's verdict under a heading `# Chairman's final verdict`.

### Step 5 — Reveal and close

After the verdict, reveal the A–E → role mapping in a small footer (`_A = Contrarian, B = Executor, ..._`) so the user can re-read with context if they want.

End by reminding the user: **the final call is theirs.** The Council is a thinking partner, not a decision-maker.

## Orchestrator rules

- Never substitute your own analysis for an advisor's. If an `Agent` call fails, retry once; if it still fails, tell the user and stop.
- Run the 5 dispatches in parallel (one message, multiple Agent tool uses) — not sequentially. Same for peer review.
- Keep your own commentary between steps minimal: one-line status updates only (e.g. "Dispatching 5 advisors...", "Running peer review...").
- Do not leak the A–E mapping before Step 5.
