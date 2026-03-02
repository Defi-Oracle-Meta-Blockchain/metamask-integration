# Chain 138 Snap — Next steps

## Completed

- [x] **GitHub repo:** https://github.com/bis-innovations/chain138-snap (pushed; includes CodeQL workflow, npm README, publish script)
- [x] **npm:** [chain138-snap@0.1.2](https://www.npmjs.com/package/chain138-snap) published; Snap ID: `npm:chain138-snap`
- [x] **CodeQL:** `.github/workflows/codeql.yml` added; Security → Code scanning will run on push/PR and weekly
- [x] **Docs:** README on npm, INTEGRATORS.md, PUSH_AND_PUBLISH.md, ALLOWLIST_FORM_FIELDS.md, ALLOWLIST_SOURCE_AND_COMPLIANCE_CHECKLIST.md
- [x] **Documentation and FAQs:** All Snap-specific docs and FAQs live in this repo. See [docs/README.md](docs/README.md) for the index. Includes: CONTRIBUTING, FAQ, DEPLOY_COMPANION_SITE, RUNBOOK. Proxmox and other proprietary/internal references have been removed from docs and scripts.

## Remaining (manual)

1. ~~**Submit for allowlist**~~ **Done** — Submitted to MetaMask Snaps Directory; pending review/approval. After allowlisting, the Snap will be installable in standard MetaMask (non-Flask).

2. ~~**Dependabot alerts**~~ **Addressed** — Added pnpm `overrides` and Yarn `resolutions` for vulnerable transitive deps (cookie, glob, sharp, socket.io, ws, path-to-regexp). Bumped `sharp` override to ^0.34.5. Snap tests fixed with `@types/jest`. Re-run Dependabot/audit after pushing; merge any new Dependabot PRs for remaining bumps.

3. **Future releases**  
   Bump version in `packages/snap/package.json`, then from this repo root run `pnpm run publish:snap`. Push to GitHub. If this repo is used as a subtree elsewhere, use your usual subtree push (e.g. `git subtree push --prefix=chain138-snap chain138-snap main` or split + force push if the remote has diverged).
