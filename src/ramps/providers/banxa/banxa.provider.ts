/**
 * Banxa on-ramp and off-ramp provider
 * Docs: https://docs.banxa.com
 */

import type { IOnRampProvider, IOffRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';

export class BanxaProvider implements IOnRampProvider, IOffRampProvider {
  readonly id = 'banxa';
  private apiKey: string;
  private baseUrl = 'https://banxa.com';

  constructor(config: { apiKey: string; baseUrl?: string }) {
    this.apiKey = config.apiKey;
    if (config.baseUrl) this.baseUrl = config.baseUrl;
  }

  async createSession(params: OnRampSessionParams): Promise<RampSession> {
    const search = new URLSearchParams({
      coinType: params.cryptoCurrency.toUpperCase(),
      fiatType: params.fiatCurrency.toUpperCase(),
      fiatAmount: params.amount,
      blockchains: this.chainToBlockchain(params.chainId),
      walletAddress: params.walletAddress,
    });
    if (params.redirectUrl) search.set('returnUrl', params.redirectUrl);
    if (params.email) search.set('email', params.email);
    const url = this.baseUrl + '/app/buy?' + search.toString();
    const sessionId = 'bx-' + Date.now() + '-' + Math.random().toString(36).slice(2, 10);
    return { url, sessionId, expiresAt: new Date(Date.now() + 30 * 60 * 1000), provider: this.id };
  }

  async createPayoutSession(params: OffRampSessionParams): Promise<RampSession> {
    const search = new URLSearchParams({
      coinType: params.cryptoCurrency.toUpperCase(),
      fiatType: params.fiatCurrency.toUpperCase(),
      cryptoAmount: params.amount,
      blockchains: this.chainToBlockchain(params.chainId),
      walletAddress: params.walletAddress,
    });
    if (params.redirectUrl) search.set('returnUrl', params.redirectUrl);
    const url = this.baseUrl + '/app/sell?' + search.toString();
    const sessionId = 'bx-sell-' + Date.now() + '-' + Math.random().toString(36).slice(2, 10);
    return { url, sessionId, expiresAt: new Date(Date.now() + 30 * 60 * 1000), provider: this.id };
  }

  private chainToBlockchain(chainId?: number): string {
    const map: Record<number, string> = { 1: 'ETH', 137: 'MATIC', 56: 'BNB', 42161: 'ARBITRUM', 10: 'OPTIMISM' };
    return chainId ? (map[chainId] ?? 'ETH') : 'ETH';
  }

  getCapabilities(): ProviderCapabilities {
    return {
      id: this.id,
      name: 'Banxa',
      onRamp: true,
      offRamp: true,
      quoteSupport: false,
      supportedChains: [1, 137, 56, 42161, 10],
      supportedFiatCurrencies: ['usd', 'eur', 'gbp', 'aud'],
      supportedCryptoCurrencies: ['eth', 'btc', 'usdc', 'usdt', 'matic', 'bnb'],
    };
  }
}
