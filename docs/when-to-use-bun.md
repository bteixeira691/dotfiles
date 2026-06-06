# When to use Bun (and when not to)

Bun is a fast JavaScript runtime + package manager + bundler + test
runner, all in one binary. It's a great fit for some workloads and a
bad fit for others.

---

## TL;DR

- **Use Bun for:** greenfield TS apps, scripts, small CLIs, monorepos
  with strict ESM, anywhere you want speed.
- **Keep npm/pnpm for:** complex projects with native node-gyp modules,
  legacy CommonJS, or strict supply-chain audit needs.
- **Don't mix** Bun runtime and npm package manager in the same project
  (lockfile conflicts).

---

## Where Bun shines

### 1. Greenfield TypeScript apps
```sh
bun create next-app myapp
cd myapp
bun dev
```
- First-class TS support, no build step needed.
- `bun run script.ts` works directly (no ts-node, tsx, etc.).

### 2. Single-file scripts
```sh
bun run ./scrape.ts
bun run ./seed-db.ts
```
- Native TS execution, no compile step.
- Built-in `bun:sqlite`, `Bun.serve`, `Bun.file`, `Bun.password`.

### 3. Install speed
```sh
bun install     # typically 5-10× faster than npm/pnpm/yarn
```
- Especially noticeable in CI.
- `bun install --frozen-lockfile` for CI.

### 4. Test runner
```sh
bun test
```
- Built-in, Jest-compatible API.
- Faster than vitest for simple cases.

### 5. Bundler
```sh
bun build ./src/index.ts --outdir ./dist --target node
```

### 6. Package runner (like npx)
```sh
bunx create-react-app myapp
bunx prettier --write .
```

---

## Where Bun struggles

### 1. Native modules (node-gyp)
Some packages have native bindings that don't work with Bun yet:
- `bcrypt` (use `bcryptjs` instead, or use Bun's built-in `Bun.password`)
- Older `node-sass`
- Some `sharp` versions
- Some electron tooling

Check the [Bun compatibility list](https://bun.sh/docs/runtime/nodejs-apis)
before adopting.

### 2. CommonJS edge cases
Bun prefers ESM. Some legacy CommonJS packages work, but with quirks.

### 3. Production stability
Bun is < 1.0. Some APIs may change. For production-critical apps,
stick with Node.js LTS.

### 4. Strict supply-chain audits
- Bun's lockfile format is different from `package-lock.json`.
- `npm audit` doesn't work with `bun.lock` (use `bun audit` instead).

### 5. Tooling assumptions
- Many tools assume Node is the runtime (e.g. eslint configs).
- Some debuggers don't yet support Bun.

---

## The hybrid approach

Use Bun as a **package manager** for projects that still run on Node:

```sh
# Use Bun for installs, but Node for runtime
bun install
node ./dist/main.js      # built with tsc or tsup
```

Or use Bun as a **runtime** with npm as the package manager:

```sh
npm install
bun run ./src/server.ts  # if you have a single-file server
```

⚠️ Pick one and stick with it per project — mixing creates lockfile
confusion.

---

## Bun in this dotfiles setup

- **Install:** `brew install bun` (mac), `pacman -S bun` (Arch),
  `bun` is in Fedora repos.
- **Default in devcontainer:** yes (the devcontainer feature installs it).
- **Default in zsh:** no — we keep `node` and `npm` as the baseline.
  Use `bun` for specific projects that opt in.

### Aliases (already in aliases.zsh)
```sh
alias bunx="bun x"
# No `bun` alias (name is short enough)
```

### When to add Bun to a project
- If `package.json` has `"type": "module"` and no native deps.
- If you're starting from scratch and TS is the main language.
- If CI install time is a bottleneck.

### When to keep npm/Node
- If the project already has a working npm/pnpm setup.
- If you have native deps.
- If you need stable, boring, well-supported runtime (production).

---

## Cheat sheet

| Action | npm | bun |
|--------|-----|-----|
| Install deps | `npm install` | `bun install` |
| Add a dep | `npm install x` | `bun add x` |
| Add dev dep | `npm install -D x` | `bun add -d x` |
| Remove a dep | `npm uninstall x` | `bun remove x` |
| Run a script | `npm run dev` | `bun run dev` |
| Run TS | `tsx script.ts` | `bun run script.ts` |
| Run a tool | `npx x` | `bunx x` |
| Test | `npm test` | `bun test` |
| Build | `npm run build` | `bun run build` / `bun build` |
| Audit | `npm audit` | `bun audit` |
| Lockfile | `package-lock.json` | `bun.lock` / `bun.lockb` |

---

## Resources

- Bun docs: https://bun.sh/docs
- Bun runtime Node compat: https://bun.sh/docs/runtime/nodejs-apis
- Bun Discord: https://bun.sh/discord
- This dotfiles repo: `~/dotfiles/docs/when-to-use-bun.md`
