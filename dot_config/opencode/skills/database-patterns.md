---
name: database-patterns
description: Relational database conventions — schema design, migrations, indexing, query patterns, transactions, connection pooling. Use when designing tables, writing migrations, optimizing queries, or reviewing DB code.
license: MIT
---

# Database Patterns

## Schema design

- **Pick the right key type.** `BIGINT` for surrogate keys, `UUID` for distributed systems, `TEXT` for natural keys.
- **Use `created_at` and `updated_at` on every table.** `TIMESTAMPTZ` (not `TIMESTAMP`) in Postgres.
- **Soft delete only when you must.** A `deleted_at` column is a tax on every query. Prefer hard delete + audit log.
- **No JSON columns by default.** Use them only for truly schemaless data. Otherwise you're hiding schema in JSON.
- **Foreign keys everywhere.** Enforce integrity at the DB layer, not the app layer.
- **Use `CHECK` constraints for invariant columns.** `CHECK (status IN ('active', 'inactive'))`.

## Naming

- **snake_case** for tables and columns.
- **Plural table names.** `users`, not `user`.
- **Singular PK column.** `id` (not `user_id` in the users table; use `user_id` in FKs).
- **`_id` suffix for FKs.** `user_id`, `order_id`.
- **Junction tables are alphabetical.** `roles_permissions` (not `permission_roles`).
- **Booleans are predicates.** `is_active`, `has_children` — not `active`, `children`.

## Migrations

- **One migration per change.** Don't bundle unrelated changes.
- **Forward and backward.** `up` and `down` migrations, both tested.
- **Never edit a merged migration.** Add a new one to fix the mistake.
- **Migrations are code.** Review them like code. Run them in CI.
- **Backfill data in a separate migration.** Don't combine schema and data.
- **Default values for non-null columns.** Avoid `NULL` in critical fields.

## Indexes

- **Index every FK.** Default. The query planner will thank you.
- **Index columns used in `WHERE`, `ORDER BY`, `GROUP BY`.**
- **Composite index: equality first, then range.** `(status, created_at)` for `WHERE status = ? ORDER BY created_at`.
- **Partial indexes for filtered queries.** `CREATE INDEX ... WHERE deleted_at IS NULL`.
- **Don't over-index.** Every index slows down writes.

## Query patterns

### Avoid N+1
```sql
-- BAD: 1 + N queries
for user in users: posts = SELECT * FROM posts WHERE user_id = user.id

-- GOOD: 1 query with JOIN
SELECT u.*, p.* FROM users u LEFT JOIN posts p ON p.user_id = u.id
```

### Avoid SELECT *
Always name the columns. `SELECT *` breaks when the schema changes and inflates row size.

### Use EXPLAIN
Run `EXPLAIN ANALYZE` on slow queries. Don't guess.

### Bound your queries
`LIMIT` is your friend. Never return an unbounded result set.

## Transactions

- **Keep transactions short.** Long transactions hold locks.
- **Use the lowest isolation level that works.** `READ COMMITTED` is usually enough.
- **Avoid deadlocks.** Always lock tables in the same order.
- **Savepoints for partial rollbacks.** Inside a long transaction.

## Connection pooling

- **Pool size: ~2x CPU cores** for OLTP workloads.
- **Pool exhaustion is a feature, not a bug.** It means you need to scale up.
- **Use `pgbouncer` or equivalent** for many short-lived connections.
- **Set `statement_timeout`** to prevent runaway queries.

## Migrations example (Rails / Alembic / Drizzle)

```ruby
# ActiveRecord
class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :status, null: false, default: 'pending'
      t.integer :total_cents, null: false
      t.timestamptz :created_at, null: false
      t.timestamptz :updated_at, null: false
      t.index :status
      t.index :created_at
    end
  end
end
```

## Anti-patterns

- ❌ `SELECT *` in production code
- ❌ `DELETE FROM users` without a `WHERE` (always, always, always bound deletes)
- ❌ Storing money in `FLOAT`/`DOUBLE` (use `INTEGER` cents or `DECIMAL`)
- ❌ Storing comma-separated values in a single column
- ❌ `NULL` for "no value" when an empty string or `0` would do
- ❌ Migrations that take a long time on a populated table (lock the table → outage)
- ❌ Unbounded `LIKE '%foo%'` queries
- ❌ Hiding schema in JSON columns
