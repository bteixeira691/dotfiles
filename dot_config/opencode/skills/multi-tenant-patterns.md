---
name: multi-tenant-patterns
description: Multi-tenant data isolation patterns for SaaS — tenant scoping, query filters, JWT claims, cross-tenant safety, testing. Use when designing or reviewing multi-tenant data layers, fixing tenant leaks, or auditing tenant isolation.
license: MIT
---

# Multi-Tenant Patterns

## The cardinal rule

**Every query that touches tenant data must filter by the current tenant.**

Forgetting this once = data breach. Make it impossible to forget.

## Tenant identification

### JWT claims (most common)
```json
{
  "sub": "user_123",
  "tenant_id": "tenant_abc",
  "roles": ["admin"]
}
```

### Resolver
```python
class TenantContext:
    def __init__(self, request):
        self.tenant_id = request.state.jwt.tenant_id
        self.user_id = request.state.jwt.sub
```

Inject the resolver into services via DI.

## ORM-level enforcement (defense in depth)

### EF Core (global query filter)
```csharp
modelBuilder.Entity<Order>()
    .HasQueryFilter(o => o.TenantId == _currentTenant.TenantId);
```

If the developer writes `db.Orders.ToList()`, the filter is auto-applied. The only way to bypass it is `.IgnoreQueryFilters()` — and that should require a code review comment.

### Prisma (middleware)
```ts
prisma.$use(async (params, next) => {
  if (params.model === 'Order') {
    if (params.action === 'findMany' || params.action === 'findFirst') {
      params.args.where = { ...params.args.where, tenantId: ctx.tenantId };
    }
  }
  return next(params);
});
```

### SQLAlchemy (event listener)
```python
@event.listens_for(Session, 'do_orm_execute')
def filter_by_tenant(state):
    if not state.is_select:
        return
    for entity in state.statement.column_descriptions:
        if entity['entity'] in TENANT_MODELS:
            state.statement = state.statement.where(
                entity['entity'].tenant_id == current_tenant_id()
            )
```

## FK constraints

```sql
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL REFERENCES tenants(id),
  ...
  FOREIGN KEY (tenant_id, customer_id) REFERENCES customers(tenant_id, id)
);
```

Compound FKs that include `tenant_id` prevent cross-tenant references at the DB level.

## Background jobs

- **Always pass `tenant_id` explicitly** when enqueuing a job. Don't rely on
  thread-local state.
- **Workers should validate** that the resource they're touching
  belongs to the tenant in the job.

```python
enqueue('send_email', tenant_id=ctx.tenant_id, user_id=ctx.user_id)
```

## Testing tenant isolation

### The "evil tenant" test
For every endpoint, write a test that:
1. Creates resource X in tenant A
2. Authenticates as a user in tenant B
3. Tries to read/write/delete X
4. Asserts 404 (or 403, but 404 is safer — don't leak existence)

```python
def test_cross_tenant_read_returns_404():
    # Create resource in tenant A
    order_a = create_order(tenant_id='A')

    # Authenticate as tenant B user
    client = client_for_tenant('B')

    # Try to read
    response = client.get(f'/orders/{order_a.id}')
    assert response.status_code == 404
```

## Auditing

- **Log every cross-tenant attempt** (even blocked ones). This is your
  canary for a real attack.
- **Per-tenant query log** for high-value operations.

## Migrations

- **All tenant tables get a `tenant_id` column** from day one. Adding it
  later is a 5-step backfill.
- **Backfill with a script** that runs in a transaction per tenant.

## Superadmin / cross-tenant access

- **Use a separate identity** (a "superadmin" role, a separate JWT
  claim, a different auth flow).
- **Bypass query filters explicitly** with `.IgnoreQueryFilters()` /
  raw SQL / a separate read replica.
- **Audit-log every cross-tenant access.** Always.

## Anti-patterns

- ❌ Tenant ID in the URL only (`/tenants/123/orders`) — easy to forge
- ❌ Tenant ID from headers without auth verification
- ❌ Passing tenant_id as a parameter to every method (defeats the type system)
- ❌ Letting a user "switch tenants" without re-auth
- ❌ Caching across tenants without keying by tenant
- ❌ Webhooks without tenant verification
- ❌ Background jobs without tenant_id in payload
- ❌ "Just use `where tenant_id = X` in the controller" — fragile

## Stack notes

- **EF Core:** global query filters + `IgnoreQueryFilters()` audit
- **Prisma:** middleware for tenant_id, never expose `tenantId` in
  mutation inputs (derive from JWT)
- **Rails (acts_as_tenant):** gem that sets `current_tenant` and applies
  it to all queries
- **Django:** custom QuerySet + middleware
- **Postgres RLS:** `CREATE POLICY tenant_isolation ON orders USING
  (tenant_id = current_setting('app.tenant_id')::int)` — defense in depth
  at the DB layer
