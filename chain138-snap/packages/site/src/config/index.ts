export { defaultSnapOrigin } from './snap';

/**
 * Token-aggregation (or market) API base URL for Snap RPCs.
 * Set GATSBY_SNAP_API_BASE_URL in .env or .env.production for production.
 */
export const getSnapApiBaseUrl = (): string =>
  (typeof process !== 'undefined' &&
    process.env?.GATSBY_SNAP_API_BASE_URL) ||
  '';

/** Build ID or git SHA for support/debug (set at build: GATSBY_BUILD_SHA, GATSBY_APP_VERSION). */
export const getBuildVersion = (): string =>
  (typeof process !== 'undefined' &&
    (process.env?.GATSBY_APP_VERSION || process.env?.GATSBY_BUILD_SHA)) ||
  '';
