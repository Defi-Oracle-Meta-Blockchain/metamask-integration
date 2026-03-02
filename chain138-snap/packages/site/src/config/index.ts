export { defaultSnapOrigin } from './snap';

/**
 * Token-aggregation (or market) API base URL for Snap RPCs.
 * Set GATSBY_SNAP_API_BASE_URL in .env or .env.production for production.
 */
export const getSnapApiBaseUrl = (): string =>
  (typeof process !== 'undefined' && process.env?.GATSBY_SNAP_API_BASE_URL) ||
  '';

/**
 * Public origin of the Snap companion site (e.g. https://explorer.d-bis.org).
 * Set GATSBY_SNAP_SITE_URL so "Send on Chain 138" link is absolute HTTPS and never redirects to HTTP.
 */
export const getSnapSiteUrl = (): string =>
  (typeof process !== 'undefined' && process.env?.GATSBY_SNAP_SITE_URL) || '';

/** Build ID or git SHA for support/debug (set at build: GATSBY_BUILD_SHA, GATSBY_APP_VERSION). */
export const getBuildVersion = (): string =>
  (typeof process !== 'undefined' &&
    (process.env?.GATSBY_APP_VERSION || process.env?.GATSBY_BUILD_SHA)) ||
  '';
