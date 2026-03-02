/**
 * The snap origin to use.
 * Will default to the local hosted snap if no value is provided in environment.
 *
 * Use GATSBY_SNAP_ORIGIN so Gatsby inlines it into the client bundle (only GATSBY_*
 * vars are exposed to the browser). E.g. GATSBY_SNAP_ORIGIN=npm:chain138-snap for production.
 */
export const defaultSnapOrigin =
  // eslint-disable-next-line no-restricted-globals
  process.env.GATSBY_SNAP_ORIGIN ??
  process.env.SNAP_ORIGIN ??
  `local:http://localhost:8080`;
