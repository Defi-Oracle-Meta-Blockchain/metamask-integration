import { isLocalSnap } from './snap';
import type { Snap } from '../types';

/**
 *
 * @param installedSnap
 */
export const shouldDisplayReconnectButton = (installedSnap: Snap | null) =>
  installedSnap && isLocalSnap(installedSnap?.id);
