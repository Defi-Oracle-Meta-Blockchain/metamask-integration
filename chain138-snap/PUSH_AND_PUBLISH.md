# Push to GitHub and publish to npm

Use this when the Snap lives in **https://github.com/bis-innovations/chain138-snap** and you are ready to push and publish.

## 1. Push to GitHub (first-time setup)

From the **chain138-snap** directory (or the repo root if this monorepo is the whole repo):

```bash
# If this folder is the repo to push (you cloned/copied it as chain138-snap):
git remote add origin https://github.com/bis-innovations/chain138-snap.git
git branch -M main
git push -u origin main
```

If this directory is part of a larger repo (e.g. `proxmox`), you can either push only the Snap subtree to **chain138-snap** (e.g. `git subtree push` or a new clone containing just the Snap), or push the whole repo and then point the Snap’s `repository` to a dedicated Snap repo. For a **standalone** Snap repo: create **bis-innovations/chain138-snap** on GitHub, then from a clone that contains only this Snap monorepo (e.g. copy `metamask-integration/chain138-snap` contents into a new repo): run the `git remote add origin` / `git push` commands above.

## 2. Publish Snap package to npm

From the **chain138-snap** monorepo root:

```bash
# Build (updates manifest shasum)
pnpm run build

# Publish the Snap package (requires npm login)
cd packages/snap && npm publish --access public
# Or: pnpm publish --no-git-checks --access public
```

Production Snap ID will be **`npm:chain138-snap`**.

## 3. Submit for allowlist

After npm publish, fill the [MetaMask Snaps Directory Information form](https://docs.metamask.io/snaps/how-to/get-allowlisted/#1-submit-your-snap) with:

- **Snap name:** Chain 138 (must match `proposedName` in `snap.manifest.json`)
- **GitHub repository:** https://github.com/bis-innovations/chain138-snap
- **npm package:** https://www.npmjs.com/package/chain138-snap
- **Version:** from `packages/snap/package.json` (e.g. 0.1.0)
- Descriptions, support details, images, optional demo video as required.

See **ALLOWLIST_SOURCE_AND_COMPLIANCE_CHECKLIST.md** for prerequisites.
