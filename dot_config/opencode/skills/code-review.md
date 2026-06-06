---
name: code-review
description: Review changed code for bugs, security, style, and design
keywords: [review, audit, check, scrutinize, lint]
---

# Code review skill

Use this skill when the user asks to review, audit, or check code.

## Process

1. **Identify the diff.** Use `git diff` (staged + unstaged) or
   `git diff main...HEAD` for a branch review.

2. **Categorize each file change:**
   - **Bug risk:** logic errors, off-by-one, null/nil/undefined, race conditions
   - **Security:** secrets, injection (SQL/cmd/path), XSS, auth, validation
   - **Style:** formatting, naming, dead code, commented-out code
   - **Design:** abstraction leaks, missing tests, brittle types, tight coupling
   - **Perf:** O(n²) loops, N+1 queries, missing indexes, sync I/O in hot path
   - **API:** breaking changes, missing error cases, missing validation

3. **For each finding, output:**
   ```
   - **[severity]** [file:line] — [description]
     - Why: [concrete impact]
     - Fix: [concrete change]
   ```
   Severities: 🔴 blocker | 🟠 major | 🟡 minor | 🟢 nit

4. **Skip** the diff if the change is trivial (formatting only, comment
   changes, lockfile bumps).

5. **Don't propose refactors** outside the diff. Stay focused.

## Output format

Start with a 1-line summary, then the findings grouped by severity.
End with a "Looks good" or "Needs changes" verdict.

Example:
```
Review: refactor user service to use async/await
Found 2 issues, both minor.

🟡 minor  src/user.py:42  — Unbounded list comprehension
  - Why: Could OOM if user has 1M records
  - Fix: Use itertools.islice or paginate

🟢 nit  tests/test_user.py:8  — Test name `test_user` is too generic
  - Fix: `test_user_creation_with_invalid_email`

Verdict: Looks good after fixing the minor issue.
```
