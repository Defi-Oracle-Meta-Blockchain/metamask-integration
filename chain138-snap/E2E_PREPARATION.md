# E2E Preparation — Token-Aggregation and Companion Site

Complete these steps so that full end-to-end testing (market data, bridge routes, swap quotes) succeeds.

---

## 1. Token-aggregation service

The Snap and companion site call the token-aggregation API for networks, token list, bridge routes, and swap quotes. You need the service running and reachable.

### Option A: Local (recommended for E2E)

1. **Prerequisites**
   - Node.js 20+
   - PostgreSQL 14+ with TimescaleDB (if your token-aggregation service uses it)
   - RPC URLs for Chain 138 and 651940 (e.g. from your API `.env.example`)

2. **Setup**
   - Clone or use your token-aggregation service repo. Copy `.env.example` to `.env` and set `DATABASE_URL`, `CHAIN_138_RPC_URL`, `CHAIN_651940_RPC_URL` (or equivalent).

3. **Database**
   - Apply migrations as required by your token-aggregation service (see that service’s QUICK_START or migration docs).

4. **Run**
   ```bash
   npm install
   npm run build
   npm run dev
   ```
   Service will listen on **http://localhost:3000**.  
   Verify: `curl http://localhost:3000/health` and `curl http://localhost:3000/api/v1/networks`.

### Option B: Docker

```bash
# From your token-aggregation service directory
# Ensure .env exists with DATABASE_URL etc.
docker-compose up -d
# API on http://localhost:3000 (or the port your service uses)
```

### Option C: Deployed / staging

Use your deployed token-aggregation base URL (e.g. `https://your-token-aggregation-api.com`). Ensure CORS allows the Snap/site origin and the endpoints below respond:

- `GET /api/v1/networks`
- `GET /api/v1/report/token-list`
- `GET /api/v1/bridge/routes`
- `GET /api/v1/quote`
- `GET /api/v1/tokens` (for market summary)

---

## 2. Companion site environment

The companion site passes `apiBaseUrl` to the Snap so that market data, bridge, and swap quote cards work.

1. **Create env file**

   ```bash
   cd packages/site
   cp .env.production.dist .env
   # or .env.production for production build
   ```

2. **Set API base URL**
   - Local token-aggregation: `GATSBY_SNAP_API_BASE_URL=http://localhost:3000`
   - Deployed: `GATSBY_SNAP_API_BASE_URL=https://your-token-aggregation-api.com`  
     Do not add a trailing slash.

3. **Restart the site** if it is already running so the variable is picked up (Gatsby reads env at build/start).

---

## 3. Run Snap + site

From the Chain 138 Snap repo root:

```bash
pnpm run start
```

- Site and Snap are served at **http://localhost:8000**.
- Open that URL in a browser where **MetaMask Flask** is installed.

---

## 4. Manual E2E checklist

Use the [E2E testing checklist (MetaMask Flask)](TESTING_INSTRUCTIONS.md#e2e-testing-checklist-metamask-flask) in `TESTING_INSTRUCTIONS.md` and complete every item (environment, install Snap, RPC methods, companion site cards).

---

## 5. Optional: automated E2E (Playwright)

To run the automated E2E tests (site loads and shows Snap Connect UI):

```bash
pnpm install
npx playwright install
pnpm run test:e2e
```

- First time: run `npx playwright install` to install browser binaries.
- `test:e2e` starts the dev server if needed and runs Playwright against http://localhost:8000.
- The **site must compile successfully** for E2E to pass (if Gatsby fails to build, fix the dev environment first).
- It does **not** drive MetaMask Flask; for full install/connect flow you must run the manual checklist.
- Optional: `pnpm run test:e2e:ui` to open the Playwright UI.

---

## 6. Run E2E against deployed Snap site

To run Playwright (or manual checks) against a **deployed** Snap companion site (e.g. https://yoursite.com/snap/):

1. **Playwright against a URL:** Set the base URL and run tests (if your Playwright config supports it), e.g.:
   - Add a config or override in `playwright.config.ts`: `baseURL: process.env.SNAP_BASE_URL || 'http://localhost:8000'`.
   - Run: `SNAP_BASE_URL=https://yoursite.com/snap pnpm run test:e2e` (after adding `baseURL` to the config).
   - Or run the manual E2E checklist in TESTING_INSTRUCTIONS.md while opening your deployed site URL in the browser.

2. **Environment:** The deployed site must be built with `GATSBY_SNAP_API_BASE_URL` set to your token-aggregation URL for Market, Bridge, and Swap cards to work. If not set, those cards will show "Set GATSBY_SNAP_API_BASE_URL".

---

**Last updated:** 2026-02-11
