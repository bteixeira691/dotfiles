---
name: react-patterns
description: React patterns for production code — component composition, state management, data fetching, forms, performance. Use when building React components, debugging React issues, or reviewing React code.
license: MIT
---

# React Patterns

## Component composition

- **One component per file.** File name matches component name.
- **Co-locate related code.** Component, styles, tests, types — all in one folder.
- **Props interface always defined and exported.**
- **Children pattern for slots.** `<Card><Title>...</Title><Body>...</Body></Card>`.
- **Composition over configuration.** Don't build `<Button variant="primary|secondary|danger" size="sm|md|lg" />` for 12 prop combos — split into `<Button>`, `<IconButton>`, etc.

## State

### Where to put state
- **Local `useState` for UI state** (toggle, hover, focus).
- **`useReducer` for state with >3 transitions.**
- **Context for cross-cutting values** (theme, auth, current user).
- **External store (Zustand / Jotai) for app-wide state.**
- **Server cache (React Query / SWR) for server data.**

### Server state vs UI state
- **Server data goes in React Query / SWR / RSC.** Never in `useState`.
- **Optimistic updates for snappy interactions** (toggles, likes, drag-drop).
- **Mutations: use `useMutation` or RSC actions, not `fetch` in `useEffect`.**

## Data fetching

### One hook per resource
```tsx
function useUser(id: string) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => api.getUser(id),
  });
}
```

The hook owns loading / error / data state. Components just call it.

### Suspense
- `useQuery({ suspense: true })` lets you wrap in `<Suspense fallback={...}>`.
- Default to Suspense for new code; use `isLoading` only for imperative cases.

## Forms (React 19)

```tsx
function NewItemForm() {
  const [state, formAction, isPending] = useActionState(submitItem, { error: null });
  return (
    <form action={formAction}>
      <input name="title" required />
      <SubmitButton />
      {state.error && <p role="alert">{state.error}</p>}
    </form>
  );
}
```

- `useActionState` for submit handlers.
- `useFormStatus` for pending UI in child components.
- Validate at the boundary (zod / valibot) and again on the server.
- `useOptimistic` for instant feedback on slow mutations.

## Performance

### Don't memo preemptively
- `memo`, `useMemo`, `useCallback` are for measured problems, not style.
- If a render is slow, profile first. Then memo.
- React Compiler (when enabled) removes most of this work.

### Avoid these in render
- Object/array literals as props (new identity every render) — unless the child is `memo`'d.
- Inline function definitions in deps arrays.

### Code splitting
- `lazy(() => import('./Heavy'))` for routes and heavy components.
- `<Suspense fallback={<Loading />}>` around them.

## Accessibility

- **Use semantic HTML.** `<button>` for actions, `<a>` for navigation, `<label htmlFor>` for inputs.
- **Don't use `<div onClick>` for buttons.** Use `<button>`.
- **Focus management:** trap focus in modals, restore focus on close.
- **`aria-*` only when semantic HTML isn't enough.** Don't add `role="button"` to a `<div>`.
- **Keyboard navigation works by default if you use semantic HTML.**
- **Color is not the only signal.** Pair color with text or icon.

## Common mistakes

- ❌ `useEffect` for derived state — compute in render
- ❌ `useEffect` for data fetching — use React Query
- ❌ `<div onClick>` — use `<button>`
- ❌ Mutating state directly — use setState
- ❌ Missing `key` prop in lists (or using index as key)
- ❌ State in the wrong place (lift up, or push down)
- ❌ Server data in `useState`

## Stack notes

- **React 19:** `useActionState`, `useOptimistic`, `use()` for promises, no `forwardRef` (ref is a regular prop).
- **TypeScript:** `strict: true`. `noUncheckedIndexedAccess: true` if allowed.
- **State:** Zustand for medium apps, Jotai for fine-grained reactivity, Redux Toolkit only if already in use.
- **Styling:** Tailwind for utility-first, CSS Modules for component-scoped, styled-components for CSS-in-JS.
