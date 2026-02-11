# Deploy Chain 138 Snap site to VMID 5000 (Production)

The Snap companion site can be published on the same host as the explorer (VMID 5000) at **https://explorer.d-bis.org/snap/** and is linked from the explorer navbar ("MetaMask Snap").

## Prerequisites

- Site built with **pathPrefix** `/snap` (so assets load under `/snap/`).
- Access to Proxmox host that runs VMID 5000 (e.g. `pct` or SSH to `PROXMOX_HOST_R630_02`).

## 1. Build for production (pathPrefix /snap)

From the Chain 138 Snap repo root:

```bash
GATSBY_PATH_PREFIX=/snap pnpm --filter site run build
```

This writes the static site into `packages/site/public/` with asset paths prefixed by `/snap/`.

## 2. Deploy to VMID 5000

**Option A – build and deploy in one go:**

```bash
./scripts/deploy-snap-site-to-vmid5000.sh --build
```

**Production build (market/bridge/swap from live API):** set `GATSBY_SNAP_API_BASE_URL` when building:

```bash
GATSBY_SNAP_API_BASE_URL=https://your-token-aggregation-api.com ./scripts/deploy-snap-site-to-vmid5000.sh --build
```

**Option B – deploy an existing build:**

```bash
./scripts/deploy-snap-site-to-vmid5000.sh
```

The script:

- Builds the site (only if `--build` is passed).
- Packs `packages/site/public/` into a tarball and deploys it to **/var/www/html/snap/** on VMID 5000.
- Works when run: **inside** the VM (direct), **on the Proxmox host** (`pct exec`), or **from a remote machine** (SSH to Proxmox, then `pct`). Set `PROXMOX_HOST_R630_02` (default `192.168.11.12`) when running remotely.

## 3. Nginx on VMID 5000

Nginx must serve the `/snap/` path so `/snap` and `/snap/` return 200. **One command from the Proxmox host** (or from a machine with SSH to the host):

```bash
cd explorer-monorepo
./scripts/apply-nginx-snap-vmid5000.sh
```

This runs `fix-nginx-serve-custom-frontend.sh` inside VMID 5000 (via `pct` or SSH). Alternatively, run the fix script **inside VMID 5000**:

- **`explorer-monorepo/scripts/fix-nginx-serve-custom-frontend.sh`** – run inside the VM. It configures (among other things):
  - `location = /snap` and `location /snap/` → alias `/var/www/html/snap/`, SPA fallback to `/snap/index.html`.

If you manage nginx by hand, add inside the HTTPS `server` block for explorer.d-bis.org:

```nginx
location /snap/ {
    alias /var/www/html/snap/;
    try_files $uri $uri/ /snap/index.html;
    add_header Cache-Control "no-store, no-cache, must-revalidate";
}
```

Then reload nginx.

## 4. Explorer integration

The explorer frontend (`explorer-monorepo/frontend/public/index.html`) has a nav link **"MetaMask Snap"** pointing to `/snap/`. After deploying the explorer frontend to VMID 5000 (e.g. `explorer-monorepo/scripts/deploy-frontend-to-vmid5000.sh`), that link will open the Snap site at https://explorer.d-bis.org/snap/.

## 5. Production Snap and API URL

- **Snap**: For production, the Snap is typically installed from the npm package or a published Snap ID; the companion site at `/snap/` is the install/connect page.
- **API**: Set `GATSBY_SNAP_API_BASE_URL` when building the site (e.g. in `packages/site/.env.production`) to your token-aggregation API base URL so the Market data, Bridge, and Swap quote cards work. Rebuild and redeploy after changing it.
- **Token / bridge list URLs:** If you use GitHub (or other) JSON URLs for token list, bridge list, or networks, pin them to a tag or commit SHA for reproducible deploys. Validate: `./scripts/validate-token-lists.sh <URL1> [URL2] ...`.

## Verification checks

After deploy, the script runs:

- `/var/www/html/snap/index.html` exists in the VM
- Nginx config has `location /snap/`
- `http://localhost/snap/` returns 200
- Response body contains Snap app content (Connect|Snap|MetaMask)

**Standalone verify (Snap only):**

```bash
cd metamask-integration/chain138-snap
./scripts/verify-snap-site-vmid5000.sh [BASE_URL]
# BASE_URL defaults to https://explorer.d-bis.org
```

**All VMID 5000 checks (explorer + API + Snap):**

```bash
cd explorer-monorepo
./scripts/verify-vmid5000-all.sh [BASE_URL]
```

This runs: Blockscout port 4000, nginx `/api/` and `/snap/`, public `/api/v2/stats`, `/api/v2/blocks`, `/api/v2/transactions`, explorer root `/`, Snap site `/snap/` (200 + content), and nginx config for `/snap/`.

## Quick reference

| Step | Command |
|------|--------|
| Build site (pathPrefix /snap) | `GATSBY_PATH_PREFIX=/snap pnpm --filter site run build` |
| Deploy (with build) | `./scripts/deploy-snap-site-to-vmid5000.sh --build` |
| Deploy (existing build) | `./scripts/deploy-snap-site-to-vmid5000.sh` |
| Update nginx on VMID 5000 | From host: `explorer-monorepo/scripts/apply-nginx-snap-vmid5000.sh` (or run `fix-nginx-serve-custom-frontend.sh` inside the VM) |
| Deploy explorer (incl. Snap link) | `explorer-monorepo/scripts/deploy-frontend-to-vmid5000.sh` |
| Verify Snap only | `./scripts/verify-snap-site-vmid5000.sh` |
| Verify all (explorer + API + Snap) | `explorer-monorepo/scripts/verify-vmid5000-all.sh` |

**URLs:** https://explorer.d-bis.org/snap/ and http://192.168.11.140/snap/ (replace IP if your VM differs). **Version/health:** https://explorer.d-bis.org/snap/version.json (build version and buildTime).

## CI (GitHub Actions)

The workflow **`.github/workflows/deploy-snap-site.yml`** runs on push to `main` (when site/snap/scripts change): it builds the site and uploads the artifact. To **run the Snap site smoke verify** after deploy, set a **repository variable** in GitHub:

- **Name:** `SNAP_VERIFY_BASE_URL`
- **Value:** e.g. `https://explorer.d-bis.org` (no trailing slash)

Then the workflow will run `verify-snap-site-vmid5000.sh` against that URL. Optional: set secret **`GATSBY_SNAP_API_BASE_URL`** so the CI build uses your production API URL.
