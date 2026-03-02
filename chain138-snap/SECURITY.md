# Security

## HTTPS only

- The Snap companion site is intended to be served over **HTTPS** in production. Avoid mixed content: ensure all API and asset URLs use HTTPS when the page is loaded over HTTPS.
- Your token-aggregation API should use HTTPS in production.

## Token-aggregation API (public)

If the token-aggregation API is publicly reachable:

- **CORS:** Configure allowed origins; avoid `*` in production if you need to restrict callers.
- **Rate limiting:** Consider rate limiting per IP or per key to reduce abuse.
- **Secrets:** Do not put API keys or admin credentials in the Snap or companion site frontend. Use env or a secrets manager for deploy/CI.

## Snap permissions

The Snap requests minimal permissions. Current (see `packages/snap/snap.manifest.json`):

- **snap_dialog:** Show dialogs (e.g. bridge routes, token list URL).
- **endowment:rpc** (dapps: true, snaps: false): Handle RPC from dApps.
- **endowment:network-access:** Fetch token list, bridge routes, market data from the configured API/URLs.

Only add permissions that the Snap actually needs. Document why each permission is required (e.g. in this file or in the Snap description).

## Dependency and supply chain

- Keep dependencies up to date (`pnpm update`, Renovate/Dependabot).
- Run `pnpm run lint` and tests before release. Watch for MetaMask Snaps API changes.

## Reporting

Report security issues privately (e.g. maintainer contact or security policy) rather than in public issues.
