# Push to GitHub and publish to npm

The Snap repo is **https://github.com/bis-innovations/chain138-snap**.

## 1. Push to GitHub

If this repo is used as a subtree (e.g. inside a parent monorepo as `chain138-snap/`), push from the parent repo root:

```bash
# One-time: add the Snap repo as a remote (if not already added)
git remote add chain138-snap https://github.com/bis-innovations/chain138-snap.git

# After making changes under chain138-snap/, commit then:
git add chain138-snap/
git commit -m "your message"
git subtree push --prefix=chain138-snap chain138-snap main
```

Use the remote name and branch that match your setup (e.g. `chain138-snap`, `main`).

## 2. Publish Snap package to npm

From the **chain138-snap** monorepo root:

```bash
# 0. (Recommended) Run thorough pre-publish testing
# See docs/PRE_PUBLISH_TESTING.md — build, logos/images, all RPC methods, companion site, Send page, production-like test.

# 1. Build (updates manifest shasum)
pnpm run build

# 2. (Optional) Use token from .env for publish (2FA bypass)
# Add NPM_ACCESS_TOKEN to .env (see .env.example). Use a Granular Access Token with
# "Publish" and "Bypass 2FA for publish" at https://www.npmjs.com/settings/~/tokens

# 3. Publish (uses NPM_ACCESS_TOKEN from .env if set)
# Run from the chain138-snap monorepo root:
pnpm run publish:snap
# Or manually: cd packages/snap && npm login && npm publish --access public
```

Production Snap ID will be **`npm:chain138-snap`**. After publish, the package will appear at https://www.npmjs.com/package/chain138-snap.

## 3. Submit for allowlist

After npm publish, fill the [MetaMask Snaps Directory Information form](https://docs.metamask.io/snaps/how-to/get-allowlisted/#1-submit-your-snap) with:

- **Snap name:** Chain 138 (must match `proposedName` in `snap.manifest.json`)
- **GitHub repository:** https://github.com/bis-innovations/chain138-snap
- **npm package:** https://www.npmjs.com/package/chain138-snap
- **Version:** from `packages/snap/package.json` (e.g. 0.1.0)
- Descriptions, support details, images, optional demo video as required.

See **ALLOWLIST_SOURCE_AND_COMPLIANCE_CHECKLIST.md** for prerequisites.
