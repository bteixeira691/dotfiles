---
name: i18n-patterns
description: Internationalization patterns for web apps — string externalization, locale handling, date/number/currency formatting, RTL support, translation workflow. Use when adding i18n to a new project, expanding locales, or fixing i18n bugs.
license: MIT
---

# i18n Patterns

## Externalize all user-facing strings

- **No hardcoded English in JSX.** Every user-facing string comes from a translation function.
- **No string concatenation in translations.** Use ICU MessageFormat for placeholders.
- **Keys are stable, values change.** Never change a key — change the value.

```tsx
// BAD
<p>Welcome, {name}!</p>

// GOOD
<p>{t('welcome', { name })}</p>

// Translation file
{
  "welcome": "Welcome, {name}!"
}
```

## ICU MessageFormat (for plurals, gender, etc.)

```json
{
  "cart_items": "{count, plural, =0 {Your cart is empty} =1 {1 item} other {# items}}",
  "shared_by": "{gender, select, male {Shared by him} female {Shared by her} other {Shared by them}}"
}
```

```tsx
t('cart_items', { count: items.length })
```

## Locale handling

- **Store the user's locale in the user profile** (default to browser's `navigator.language`).
- **Persist in a cookie** for anonymous users.
- **Pass as a URL param for SSR**: `?lang=pt`.
- **Accept-Language header** for API responses.

## Date / number / currency

- **Use `Intl.DateTimeFormat`, not moment.js or date-fns** (for basic cases).
- **Always set the locale explicitly** in code: `new Intl.DateTimeFormat('pt-BR')`.
- **Currency: explicit code + amount.** `EUR 9,99` or `$9.99` — pick a convention.

```js
new Intl.DateTimeFormat('en-US', { dateStyle: 'medium' }).format(date)
// → "Jun 5, 2026"

new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(9.99)
// → "R$ 9,99"
```

## Layout for internationalization

- **Strings can be 30% longer in German.** Design for it.
- **Use CSS `min-width` and `flex` for buttons/headers**, not fixed widths.
- **Test in your longest locale** before shipping.
- **Icon + text, not icon-only.** Text expands in other languages; icons don't.

## RTL (right-to-left)

- **Use `dir="rtl"` on the root element.**
- **Logical CSS properties:** `margin-inline-start` not `margin-left`.
- **Test in Arabic or Hebrew** before claiming RTL support.
- **Don't hardcode icon directions.** Use `transform: scaleX(-1)` if needed, or icon variants.

## Translation workflow

- **Source of truth: the English file.**
- **PRs to translation files from translators** (or a tool like Crowdin, Lokalise, Phrase).
- **CI check for missing keys.** Compare `en.json` to all other locales.
- **Fallback to English if a key is missing** in the user's locale.

## Pseudo-localization for testing

- **Accent characters, longer strings, brackets around text** — find i18n bugs before translators do.
- Tools: `pseudo-localization` (npm), or build it yourself in tests.

## Anti-patterns

- ❌ Concatenating translated strings: `t('hello') + name + t('world')`
- ❌ Embedding markup in translations: `"welcome": "<b>Hello</b> {name}"`
- ❌ Hardcoded locale in code: `new Intl.DateTimeFormat('en-US')` (use a variable)
- ❌ Storing dates as strings (use ISO 8601 in storage, format at render time)
- ❌ Date.now() in components (use the user's clock, not server's)
- ❌ Plural forms hardcoded: `"1 item"` vs `"2 items"` (use ICU)

## File layout

```
locales/
├── en.json
├── pt.json
├── es.json
└── de.json

# Or per-namespace:
locales/
├── en/
│   ├── common.json
│   ├── auth.json
│   └── billing.json
├── pt/
│   ├── common.json
│   └── ...
```

Per-namespace is better for large projects (load only what's needed).

## Library choice

- **i18next + react-i18next** (most popular for React)
- **next-intl** (for Next.js)
- **FormatJS / react-intl** (ICU-first)
- **Lingui** (compile-time, smaller bundle)
- **Built-in `Intl.*`** for format helpers (no library needed for basic cases)
