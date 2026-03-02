/**
 * Transak on-ramp and off-ramp provider
 * Docs: https://docs.transak.com
 */

import type { IOnRampProvider, IOffRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';

export class TransakProvider implements IOnRampProvider, IOffRampProvider {
  readonly id = 'transak';
  private apiKey: string;
  private baseUrl = 'https://global.transak.com';

  constructor(config: { apiKey: string; baseUrl?: string }) {
    this.apiKey = config.apiKey;
    if (config.baseUrl) this.baseUrl = config.baseUrl;
  }

  async createSession(params: OnRampSessionParams): Promise<RampSession> {
    const search = new URLSearchParams({
      apiKey: this.apiKey,
      walletAddress: params.walletAddress,
      defaultCryptoCurrency: params.cryptoCurrency,
      defaultFiatCurrency: params.fiatCurrency,
      defaultFiatAmount: params.amount,
    });
    if (params.chainId) search.set('networks', this.chainToNetwork(params.chainId));
    if (params.redirectUrl) search.set('redirectURL', params.redirectUrl);
    if (params.email) search.set('email', params.email);

    const url = `${this.baseUrl}/?${search.toString()}`;
    const sessionId = `tk-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

    return {
      url,
      sessionId,
      expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      provider: this.id,
    };
  }

  async createPayoutSession(params: OffRampSessionParams): Promise<RampSession> {
    const search = new URLSearchParams({
      apiKey: this.apiKey,
      walletAddress: params.walletAddress,
      defaultCryptoCurrency: params.cryptoCurrency,
      defaultFiatCurrency: params.fiatCurrency,
      defaultCryptoAmount: params.amount,
    });
    if (params.chainId) search.set('networks', this.chainToNetwork(params.chainId));
    if (params.redirectUrl) search.set('redirectURL', params.redirectUrl);

    const url = `${this.baseUrl}/?${search.toString()}&defaultScreen=selling`;
    const sessionId = `tk-sell-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

    return {
      url,
      sessionId,
      expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      provider: this.id,
    };
  }

  private chainToNetwork(chainId: number): string {
    const map: Record<number, string> = {
      1: 'ethereum',
      137: 'polygon',
      56: 'bsc',
      42161: 'arbitrum',
      10: 'optimism',
      8453: 'base',
    };
    return map[chainId] ?? 'ethereum';
  }

  getCapabilities(): ProviderCapabilities {
    return {
      id: this.id,
      name: 'Transak',
      onRamp: true,
      offRamp: true,
      quoteSupport: false,
      supportedChains: [1, 137, 56, 42161, 10, 8453],
      supportedFiatCurrencies: ['usd', 'eur', 'gbp', 'inr'],
      supportedCryptoCurrencies: ['eth', 'btc', 'usdc', 'usdt', 'matic', 'bnb'],
    };
  }
}
