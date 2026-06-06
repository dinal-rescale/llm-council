# LLM Council — improvement backlog

Open ideas for future work, grounded in Karpathy's original [llm-council](https://github.com/karpathy/llm-council) and the single-model adaptation in [this writeup](https://solopreneurcode.substack.com/p/how-i-built-the-llm-council-inside).

## Done

- **Peer-review anonymity fix** — advisor outputs are normalized into one identical neutral template before being shuffled into A–E, so role-branded headings/labels no longer reveal authorship to peer reviewers. (commit `3b34f49`)
- **Structured ranking** — peer reviewers emit a `FINAL RANKING:` line; the orchestrator aggregates it and passes the consensus order to the chairman. (commit `3b34f49`)

## Open

### 1. Skip-if-unanimous
If all 5 advisors substantially agree, skip the peer-review round and tell the user the question wasn't contentious enough to need the full council. Saves a 5-agent pass.
- **Where:** `commands/council.md`, between Step 1 and Step 2 — add a convergence check.
- **From:** the article's "Decision 3" (skip Stage 2 on unanimous agreement).

### 2. Swappable lenses
The 5 advisor roles are currently hardcoded. Let `/council` pick a roster suited to the question (e.g. swap in "The Economist" for a pricing decision, "The Teacher" for an explanation), or let the user override the roster via the command argument.
- **Where:** `commands/council.md` Step 1 + possibly new advisor files in `agents/`.
- **From:** the article's "Decision 2" (perspectives are swappable lenses, not fixed).
- **Tradeoff:** more flexible, but loses the predictable fixed-panel behavior; needs a default roster.

### 3. Total word cap / terse mode
Each piece is capped (~400 words/advisor, ~600/chairman) but the full transcript (5 analyses + 5 reviews + verdict) balloons. Add a "verdict-only" terse mode that suppresses the intermediate displays and shows just the chairman's TL;DR + verdict.
- **Where:** `commands/council.md` — gate the `## Anonymized advisor outputs` and `## Peer review` displays behind a flag.
- **From:** the article's "Decision 5" (~800-word total cap).

### 4. Single-model consensus caveat
All five "advisors" share one underlying model, so apparent consensus is weaker evidence than five genuinely independent frontier models agreeing. Add a one-line disclaimer in the chairman's verdict so the user doesn't over-trust agreement.
- **Where:** `agents/council-chairman.md` output format, or appended by `commands/council.md` at close.
- **From:** the article's limitations section (single-model deliberation ≠ true model diversity).

### 5. Chairman label-blindness (minor)
The chairman also receives the normalized A–E bundle, so it can't be biased by role identity either — this is intentional and currently correct. Documented here so a future edit doesn't accidentally re-introduce role labels into the chairman's input.
