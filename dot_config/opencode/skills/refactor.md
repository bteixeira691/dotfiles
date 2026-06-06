---
name: refactor
description: Refactor code while preserving behavior
keywords: [refactor, clean up, restructure, simplify, extract, rename]
---

# Refactor skill

Use this skill when the user asks to refactor, clean up, or restructure code
without changing observable behavior.

## Rules

1. **Tests first.** Ensure tests exist for the code being refactored.
   If they don't, write them first (or refuse and ask the user).
2. **No behavior change.** If a test fails after the refactor, fix the
   refactor, not the test.
3. **Smallest possible diff.** Refactors should be reviewable in one sitting.
4. **Atomic commits.** One refactor = one logical change = one commit.
5. **Don't expand scope.** Don't "fix" unrelated code while refactoring.

## Patterns

### Extract function
- Identify a code block with a single responsibility
- Give it a name that describes the *what*, not the *how*
- Take the minimum params needed
- Replace the original block with a call
- Move tests for the new function

### Rename
- Use the project's IDE/lsp-aware rename (not text replace)
- Update all callers in one pass
- Update docstrings, comments, type stubs

### Replace conditional with polymorphism
- Identify a switch/match on type
- Introduce an interface
- Move branches into implementations
- Inject the right implementation

### Introduce parameter object
- Find functions with 3+ related params
- Group them into a struct/dict
- Update call sites

## Output format

```
## Refactor: [goal]

### Plan
1. [step]
2. [step]
3. [step]

### Estimated diff size
- [N] files
- [~N] lines changed
- [N] new tests / [N] updated tests

### Risk
- [low/medium/high] — [reason]

### Out of scope
- [things I will NOT touch in this refactor]
```

Always state the risk and the out-of-scope list before starting.
