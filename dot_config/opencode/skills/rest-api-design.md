---
name: rest-api-design
description: REST API design conventions — endpoint shape, status codes, error format, pagination, versioning, idempotency. Use when designing or reviewing any HTTP API.
license: MIT
---

# REST API Design

## Endpoint shape

- **Nouns, not verbs.** `GET /users`, not `getUsers`. Verbs live in HTTP methods.
- **Plural resources.** `/users/123`, not `/user/123`.
- **Nested for ownership.** `GET /users/123/orders` (one user, their orders).
- **Flat for cross-cutting.** `GET /search?q=...` (no nesting).
- **Kebab-case for multi-word.** `/order-items`, `/user-profiles`.

## HTTP methods

| Method | Idempotent | Safe | Body | Use |
|--------|------------|------|------|-----|
| GET    | yes        | yes  | no   | Read |
| POST   | no         | no   | yes  | Create |
| PUT    | yes        | no   | yes  | Replace |
| PATCH  | no         | no   | yes  | Partial update |
| DELETE | yes        | no   | no   | Delete |

## Status codes

- **2xx Success:** 200 OK, 201 Created, 204 No Content
- **3xx Redirect:** 301 Moved Permanently, 304 Not Modified
- **4xx Client error:** 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 409 Conflict, 422 Unprocessable Entity, 429 Too Many Requests
- **5xx Server error:** 500 Internal Server Error, 502 Bad Gateway, 503 Service Unavailable

Use the most specific code. 422 for validation errors, 409 for state conflicts, 401 vs 403 for "no creds" vs "wrong perms".

## Error format

```json
{
  "error": {
    "code": "user_not_found",
    "message": "User 123 does not exist",
    "details": { "user_id": "123" },
    "trace_id": "abc-def-ghi"
  }
}
```

Stable error codes (snake_case strings, not localized). Include trace_id for support.

## Pagination

- **Cursor-based for large/streaming data.** `?after=xxx&limit=20`. More reliable.
- **Offset-based for small/admin UIs.** `?page=2&per_page=20`. Easier UX.
- **Always return total + has_more** (or a `next_cursor`).

```json
{
  "data": [...],
  "pagination": {
    "total": 1234,
    "page": 2,
    "per_page": 20,
    "has_more": true
  }
}
```

## Versioning

- **URL path for breaking changes:** `/v1/users`, `/v2/users`.
- **Header for non-breaking changes:** `Accept: application/vnd.api+json;version=1.1`.
- **Sunset header for deprecation:** `Sunset: Sat, 01 Jan 2027 00:00:00 GMT`.

## Idempotency

- For POST /payments / POST /refunds, accept an `Idempotency-Key` header.
- Store the key + response for 24h.
- Replay returns the original response.

## Authentication

- **Bearer tokens (JWT or opaque).** `Authorization: Bearer <token>`.
- **Never put tokens in URLs.** URLs end up in logs.
- **Refresh tokens separately from access tokens.** Short-lived access, long-lived refresh.

## Rate limiting

- Return `429` with `Retry-After` header.
- Expose `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`.
- Use sliding window for fairness.

## Conventions

- **JSON for body.** Avoid XML unless required by domain.
- **ISO 8601 for dates.** `2026-06-05T14:30:00Z`.
- **snake_case for JSON keys** (matches most languages).
- **No trailing slashes in paths.**

## Anti-patterns

- ❌ Verbs in URLs (`/getUsers`, `/createOrder`)
- ❌ Returning 200 with an error in the body
- ❌ Inconsistent error format
- ❌ Returning HTML error pages from a JSON API
- ❌ PUT/POST without idempotency for non-safe operations
- ❌ Embedding sensitive data in URLs (query params, path params)
- ❌ 200 OK with `[]` vs 404 for "not found" — pick one, document it
