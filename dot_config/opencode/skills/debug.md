---
name: debug
description: Find and fix a bug
keywords: [debug, fix, broken, fails, error, exception, bug, crash]
---

# Debug skill

Use this skill when the user reports a bug, an error, or unexpected behavior.

## The debugging ladder (use this order)

### 1. Reproduce
- Get a minimal repro. If the user has one, run it. If not, help them
  build one.
- **Reproduce first, fix later.** Don't guess.

### 2. Localize
- Bisect: `git bisect` if it's a regression.
- Print/log strategically: add 1-2 well-placed prints or use a debugger.
- Read the stack trace bottom-up (root cause is at the bottom).
- Check the obvious: typos, null/undefined, off-by-one, wrong env var,
  wrong branch checked out, stale build.

### 3. Hypothesize
- Form ONE specific hypothesis.
- State what evidence would confirm or refute it.
- Test the hypothesis with a focused experiment.

### 4. Confirm
- If the experiment confirms, you've found the root cause.
- If not, form a new hypothesis and return to step 3.
- Don't go past 5 hypotheses without asking the user for context.

### 5. Fix
- Make the smallest possible change.
- Don't refactor while fixing.
- Add a test that fails before the fix and passes after.
- Run the full test suite to check for regressions.

## Tools to use (in order of preference)

1. **The actual error message.** Read it carefully.
2. **Stack trace.** Bottom frame first.
3. **Logging output.** Grep for the error code or message.
4. **LSP / type checker.** Type errors often surface bugs.
5. **Debugger.** `lldb`, `gdb`, `pdb`, Chrome DevTools, etc.
6. **Bisect.** `git bisect run` to find the commit.
7. **Strace / dtrace / dtruss.** Last resort for syscalls.

## Questions to ask the user

If you can't reproduce or localize, ask:
- "What command / input triggers this?"
- "What did you expect to happen?"
- "What actually happened? (full error, please)"
- "When did this start? What changed?"
- "Can you share the minimal repro?"

## Output format

```
## Repro
[steps to reproduce, or "user-provided"]

## Root cause
[file:line] — [one-sentence explanation]

## Fix
[the change, with the diff]

## Test
[the test that covers the regression]

## Verification
- [x] Repro now passes
- [x] Full test suite passes
- [x] No new warnings from the linter
```
