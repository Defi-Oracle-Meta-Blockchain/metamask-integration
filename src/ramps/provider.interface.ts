/**
 * Ramp provider interfaces for fiat on/off-ramp integrations
 */

import type {
  OnRampSessionParams,
  OffRampSessionParams,
  RampQuoteParams,
  RampSession,
  RampQuote,
  ProviderCapabilities,
} from './types';

export interface IOnRampProvider {
  readonly id: string;
  createSession(params: OnRampSessionParams): Promise<RampSession>;
  getCapabilities(): ProviderCapabilities;
}

export interface IOffRampProvider {
  readonly id: string;
  createPayoutSession(params: OffRampSessionParams): Promise<RampSession>;
  getCapabilities(): ProviderCapabilities;
}

export interface IRampQuoteProvider {
  readonly id: string;
  getQuote(params: RampQuoteParams): Promise<RampQuote | null>;
  getCapabilities(): ProviderCapabilities;
}

export type RampProvider = IOnRampProvider | IOffRampProvider | IRampQuoteProvider;
