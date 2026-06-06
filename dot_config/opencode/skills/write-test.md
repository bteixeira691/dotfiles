---
name: write-test
description: Write unit tests for code
keywords: [test, spec, coverage, pytest, jest, cargo test, go test]
---

# Write-test skill

Use this skill when the user asks to add tests, write a test for X,
or improve test coverage.

## Process

1. **Find the code to test.** Use Grep/Glob to find the function, class,
   or module.
2. **Find existing tests.** Look for `tests/`, `__tests__/`, `*_test.go`,
   `*.test.ts`, `test_*.py` near the code. Mimic the project's test style.
3. **Identify the framework.** Don't introduce a new one.
4. **List the cases.** Enumerate inputs, edge cases, error paths.
5. **Write the tests.** One assertion per test (or closely related
   group). Use the project's assertion style.
6. **Run the tests.** Fix any flakiness before reporting done.

## Case categories (cover all that apply)

- **Happy path:** typical input → expected output
- **Boundary:** empty, single, max, min
- **Error:** invalid input, missing deps, network failures
- **State:** mutates state correctly, doesn't mutate what it shouldn't
- **Concurrency:** race conditions, idempotency
- **Property-based:** invariants that should always hold (use `hypothesis` /
  `fast-check` / `proptest`)

## Test naming

Follow the project's convention. If none:
- Python (pytest): `test_<unit>_<scenario>_<expected_outcome>`
  e.g. `test_user_create_with_invalid_email_raises_value_error`
- TypeScript (jest/vitest): `it('does X when Y')` or `describe('X')`
- Rust: `<module>_<scenario>_<expected_outcome>`
- Go: `TestXxx_Yyy`

## Anti-patterns

- ❌ Tests that depend on test order
- ❌ Tests that hit real network/DB (use mocks or testcontainers)
- ❌ Tests that sleep (use `waitFor` or mock the clock)
- ❌ Tests that depend on the current time/date (mock `now()`)
- ❌ Tests that share state via globals
- ❌ Tests with no assertions (use `--bail` or comment why)
- ❌ Tests with magic numbers that aren't explained

## Output

```
## Test plan
- File: `tests/test_foo.py`
- Cases: [list]

## Implementation
[the test code]

## Result
[test runner output]
```
