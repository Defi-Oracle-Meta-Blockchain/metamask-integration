# Deploy the companion site

The companion site (`packages/site`) is a Gatsby app that lets users connect to and test the Snap. You can build it and deploy it to any static host (e.g. GitHub Pages, Netlify, or your own server).

## Build

From the repo root:

```bash
# Build with path prefix (e.g. /snap if served at https://yoursite.com/snap/)
GATSBY_PATH_PREFIX=/snap pnpm --filter site run build

# With production API URL (so Market data, Bridge, Swap cards work)
GATSBY_SNAP_API_BASE_URL=https://your-token-aggregation-api.com GATSBY_PATH_PREFIX=/snap pnpm --filter site run build
```

- Output is in `packages/site/public/`. Asset paths are prefixed by `GATSBY_PATH_PREFIX` (e.g. `/snap/`).
- Use `GATSBY_PATH_PREFIX=/` if the site is served at the root of your domain.

## Deploy to your host

1. **Upload** the contents of `packages/site/public/` to your web server (e.g. `/var/www/html/snap/` or your CDN).
2. **Web server:** Ensure the server serves the SPA correctly:
   - For a path like `/snap/`, map `/snap` and `/snap/*` to the built files and use a fallback to `/snap/index.html` for client-side routing.
   - Example (nginx):

   ```nginx
   location /snap/ {
       alias /var/www/html/snap/;
       try_files $uri $uri/ /snap/index.html;
       add_header Cache-Control "no-store, no-cache, must-revalidate";
   }
   ```

3. **HTTPS:** Serve the site over HTTPS in production (see [SECURITY.md](../SECURITY.md)).

## Environment variables (build time)

| Variable                   | Description                                                                                         |
| -------------------------- | --------------------------------------------------------------------------------------------------- |
| `GATSBY_PATH_PREFIX`       | Path prefix (e.g. `/snap`). Default: none (root).                                                   |
| `GATSBY_SNAP_API_BASE_URL` | Token-aggregation API base URL passed to the Snap for market data, bridge, swap. No trailing slash. |
| `GATSBY_SNAP_SITE_URL`     | Public origin of the companion site (e.g. `https://explorer.d-bis.org`). When set, the "Send on Chain 138" link is absolute HTTPS so it never redirects to HTTP. |
| `GATSBY_BUILD_SHA`         | Optional; written to `version.json` for display.                                                    |

Set these when running the build; they are baked into the static output.

## Verification

After deploy, open your site URL and confirm:

- The Snap Connect UI loads.
- Connecting with MetaMask (or MetaMask Flask) installs the Snap.
- If you set `GATSBY_SNAP_API_BASE_URL`, the Market data, Bridge, and Swap quote cards work when the API is reachable.

## Optional: validate token/list URLs

If you use external JSON URLs for networks, token list, or bridge list, you can validate them before deploy:

```bash
./scripts/validate-token-lists.sh [URL1] [URL2] ...
# Or set TOKEN_LIST_JSON_URL, BRIDGE_LIST_JSON_URL, NETWORKS_JSON_URL
```

See script help for details.
