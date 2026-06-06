---
name: react-ts-patterns
description: React + TypeScript advanced patterns — type-safe state, discriminated unions, branded types, React 19 forms, real-time, and performance optimization
license: MIT
---

# React + TypeScript Patterns

Advanced patterns for type-safe React applications with TypeScript
strict mode.

## TypeScript patterns

### Branded types for IDs

```typescript
type Brand<T, B> = T & { __brand: B }
type UserId = Brand<string, 'UserId'>
type BookingId = Brand<string, 'BookingId'>

function getUser(id: UserId): User { /* ... */ }
function getBooking(id: BookingId): Booking { /* ... */ }

// Compile-time safety — can't mix up IDs
getUser(bookingId)  // ❌ Type error
getUser(userId)     // ✅ Correct
```

### Discriminated unions for async state

```typescript
type AsyncState<T, E = Error> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: E }

function useUser(id: UserId): AsyncState<User> {
  const [state, setState] = useState<AsyncState<User>>({ status: 'idle' })
  // ...
  return state
}
```

### Zod schema → inferred types

```typescript
const BookingSchema = z.object({
  id: z.string().uuid(),
  customerId: z.string().uuid(),
  status: z.enum(['pending', 'confirmed', 'cancelled']),
  lines: z.array(z.object({
    productId: z.string().uuid(),
    quantity: z.number().int().positive(),
  })),
})

type Booking = z.infer<typeof BookingSchema>

// Parse at the boundary — trust internally
const booking = BookingSchema.parse(response.data)
```

### `satisfies` narrowing

```typescript
const variants = {
  primary: 'bg-blue-500 text-white',
  secondary: 'bg-gray-500 text-white',
  danger: 'bg-red-500 text-white',
} satisfies Record<string, string>

type Variant = keyof typeof variants
// "primary" | "secondary" | "danger"
```

## React 19 form patterns

### useActionState

```typescript
interface FormState {
  error?: string
  fields?: Record<string, string>
}

async function submitBooking(
  prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const parsed = BookingSchema.safeParse(Object.fromEntries(formData))
  if (!parsed.success) return { error: 'Invalid data', fields: Object.fromEntries(formData) }
  // ... server action
  return {}
}

function BookingForm() {
  const [state, formAction, isPending] = useActionState(submitBooking, {})

  return (
    <form action={formAction}>
      {state.error && <div role="alert">{state.error}</div>}
      <input name="customerId" defaultValue={state.fields?.customerId} />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Submitting...' : 'Create Booking'}
      </button>
    </form>
  )
}
```

### useOptimistic

```typescript
function BookingList({ bookings }: { bookings: Booking[] }) {
  const [optimisticBookings, addOptimistic] = useOptimistic(
    bookings,
    (state, newBooking: Booking) => [...state, newBooking]
  )

  async function handleCreate(formData: FormData) {
    const newBooking = { id: crypto.randomUUID(), status: 'pending' } as Booking
    addOptimistic(newBooking)
    await createBooking(formData)
  }

  return (
    <ul>
      {optimisticBookings.map(b => (
        <li key={b.id}>{b.id} — {b.status}</li>
      ))}
    </ul>
  )
}
```

## React Query patterns

```typescript
// Typed query keys
const bookingKeys = {
  all: ['bookings'] as const,
  list: (filters: BookingFilters) => ['bookings', 'list', filters] as const,
  detail: (id: BookingId) => ['bookings', 'detail', id] as const,
}

// Typed query hook
function useBooking(id: BookingId) {
  return useQuery({
    queryKey: bookingKeys.detail(id),
    queryFn: () => api.get(`/api/bookings/${id}`).json<Booking>(),
    enabled: !!id,
  })
}

// Optimistic mutation
function useCreateBooking() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: CreateBookingRequest) =>
      api.post('/api/bookings', { json: data }).json<Booking>(),
    onSuccess: (newBooking) => {
      queryClient.setQueryData(bookingKeys.detail(newBooking.id), newBooking)
      queryClient.invalidateQueries({ queryKey: bookingKeys.all })
    },
  })
}
```

## Real-time (SignalR) patterns

```typescript
// Typed hub connection
interface BookingHubEvents {
  bookingCreated: (booking: Booking) => void
  bookingUpdated: (booking: Booking) => void
  bookingCancelled: (bookingId: string) => void
}

// Typed hook
function useBookingHub(bookingId: BookingId) {
  const [connection] = useState(() =>
    new HubConnectionBuilder()
      .withUrl('/hubs/bookings')
      .withAutomaticReconnect()
      .build()
  )

  useEffect(() => {
    connection.start()
    return () => { connection.stop() }
  }, [connection])

  return connection as TypedSignalR<BookingHubEvents>
}
```

## Performance patterns

- **`React.memo`** only for components that re-render with same props
  due to parent re-renders (measure first, don't pre-optimize)
- **`useMemo`** for expensive computations, not reference stability
- **`useCallback`** when passing callbacks to memo'd children
- **Code splitting** with `React.lazy` + `Suspense` per route
- **Bundle analysis** with `vite-bundle-visualizer` or `source-map-explorer`
- **Image optimization:** `next/image` or manual `srcset` + `loading="lazy"`

## Anti-patterns

- ❌ `useEffect` for derived state — compute in render
- ❌ `useEffect` for data fetching — use React Query or `use()`
- ❌ `any` in type positions — use `unknown` + guards
- ❌ Mutating React Query cache directly without `queryClient.setQueryData`
- ❌ Inline `fetch()` calls in components — extract to API layer
- ❌ Not handling loading/error states in every feature

## See also

- [react-patterns](../react-patterns/SKILL.md)
- [addyosmani/agent-skills: frontend-ui-engineering](../.agents/skills/frontend-ui-engineering/SKILL.md)
- [addyosmani/agent-skills: performance-optimization](../.agents/skills/performance-optimization/SKILL.md)
