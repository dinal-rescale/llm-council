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

### Step 2 — Anonymize

Collect the 5 returned analyses. Relabel them as **Advisor A, B, C, D, E** in a randomized order (do not preserve the dispatch order — shuffle). Keep a private mapping in your head; do NOT reveal which advisor is which until after the chairman's verdict.

Display the 5 anonymized outputs to the user under a heading `## Anonymized advisor outputs`.

### Step 3 — Peer review pass

In a single message, make 5 parallel `Agent` calls — one per advisor, again — but this time pass them the anonymized bundle of all 5 responses (including their own, which they won't recognize since it's relabeled) and ask them to peer-review.

Use this prompt for each peer-review call:
```
You are reviewing 5 anonymized analyses of the following decision:

<verbatim $ARGUMENTS>

Here are the 5 analyses, labeled A–E:

<full anonymized bundle>

In under 150 words, answer:
1. Which letter gave the strongest overall answer, and why?
2. Which letter has the biggest blind spot, and what is it?
3. What is missing from ALL 5 analyses collectively?

Do not try to identify which advisor wrote which — just reason from the content.
```

Display the 5 peer reviews under a heading `## Peer review`.

### Step 4 — Chairman synthesis

Dispatch the `council-chairman` agent with:
- The original decision
- The 5 anonymized analyses (A–E)
- The 5 peer-review notes

Use this prompt:
```
The user's decision:

<verbatim $ARGUMENTS>

The 5 anonymized advisor analyses:

<full anonymized bundle>

The 5 peer-review notes:

<full peer-review bundle>

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
