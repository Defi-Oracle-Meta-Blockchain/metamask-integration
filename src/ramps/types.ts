/**
 * Ramp module types for fiat on/off-ramp integrations
 */

export interface OnRampSessionParams {
  walletAddress: string;
  amount: string;
  fiatCurrency: string;
  cryptoCurrency: string;
  chainId?: number;
  email?: string;
  redirectUrl?: string;
  metadata?: Record<string, string>;
}

export interface OffRampSessionParams {
  walletAddress: string;
  amount: string;
  fiatCurrency: string;
  cryptoCurrency: string;
  chainId?: number;
  destinationAccount?: string;
  redirectUrl?: string;
  metadata?: Record<string, string>;
}

export interface RampQuoteParams {
  amount: string;
  fiatCurrency: string;
  cryptoCurrency: string;
  side: 'buy' | 'sell';
  chainId?: number;
}

export interface RampSession {
  url: string;
  sessionId: string;
  expiresAt: Date;
  provider: string;
}

export interface RampQuote {
  rate: string;
  fees: string;
  estimatedAmount: string;
  provider: string;
  expiresAt?: Date;
}

export interface ProviderCapabilities {
  id: string;
  name: string;
  onRamp: boolean;
  offRamp: boolean;
  quoteSupport: boolean;
  supportedChains?: number[];
  supportedFiatCurrencies?: string[];
  supportedCryptoCurrencies?: string[];
}
