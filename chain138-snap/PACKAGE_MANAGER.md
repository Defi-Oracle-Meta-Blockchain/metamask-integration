# Package manager

**Default:** [pnpm](https://pnpm.io) (fast, disk-efficient, single lockfile).

**Preferred alternative:** [Yarn](https://yarnpkg.com) is supported; use it if you prefer.

## Setup

1. **pnpm (default)**
   - Ensure [Corepack](https://nodejs.org/api/corepack.html) is enabled: `corepack enable`
   - Install: `pnpm install`
   - Scripts: `pnpm run build`, `pnpm run start`, `pnpm run test`, etc.
   - Commit `pnpm-lock.yaml` so CI and others use the same dependency tree.

2. **Yarn (alternative)**
   - Use existing `.yarnrc.yml` and Yarn 3.2.1.
   - Install: `yarn install`
   - Scripts: `yarn build`, `yarn start`, `yarn test`, etc.
   - Root `packageManager` is set to pnpm; if you use Yarn only, run `yarn install` and ignore `pnpm-lock.yaml`.

## CI

GitHub Actions use **pnpm** by default: `corepack prepare pnpm@9.15.0 --activate` then `pnpm install --frozen-lockfile` and `pnpm run build` / `pnpm run lint` / `pnpm --filter snap run test`. **Before the first CI run** (or after adding dependencies), run `pnpm install` locally and commit `pnpm-lock.yaml` so CI has a lockfile.

## Recommendations

- Use **pnpm** for consistency with CI and docs.
- Use **Yarn** if your tooling or team already standardizes on it; scripts in `package.json` are written for pnpm but Yarn can run the same targets (`yarn build`, etc.) from the root.
- Do not mix lockfiles in the same branch: use either `pnpm-lock.yaml` or `yarn.lock`, not both, to avoid drift.
