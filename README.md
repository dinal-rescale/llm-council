# LLM Council

Stress-test a decision with five AI advisors, anonymous peer review, and a chairman synthesis — all from one Claude Code command.

Based on Ole Lehmann's single-model variant of Andrej Karpathy's LLM Council idea.

## How it works

Run `/council <your decision>` and the orchestrator:

1. **Dispatches 5 advisors in parallel**, each with a distinct thinking style:
   - **Contrarian** — finds flaws, failure modes, weak assumptions
   - **First-principles** — rebuilds the decision from foundational truths
   - **Expansionist** — finds overlooked upside and larger framings
   - **Outsider** — reacts as a naive, domain-free observer
   - **Executor** — pressure-tests whether it can actually be executed
2. **Anonymizes** the outputs (relabeled A–E, shuffled).
3. **Runs an anonymous peer-review pass** — each advisor critiques the full bundle without knowing which is which.
4. **Chairman synthesizes** a final verdict with a mandatory TL;DR and confidence level.
5. **Reveals** the A–E → role mapping at the end.

The final call is always yours — the Council is a thinking partner, not a decision-maker.

## Install

```bash
./install.sh
```

This copies the files into `~/.claude/agents/` and `~/.claude/commands/`. Restart Claude Code afterward.

To install into a non-default config dir: `CLAUDE_HOME=/path/to/.claude ./install.sh`

### Manual install

Copy `commands/council.md` into `~/.claude/commands/` and the six `agents/council-*.md` files into `~/.claude/agents/`.

## Usage

```
/council Should we rewrite the billing service in Go or keep iterating on the Python one?
```

If you run `/council` with no argument, it asks you to state the decision first.

## What's in here

```
commands/council.md            the /council orchestrator
agents/council-contrarian.md
agents/council-first-principles.md
agents/council-expansionist.md
agents/council-outsider.md
agents/council-executor.md
agents/council-chairman.md
```

No code, no dependencies — just markdown prompts.
