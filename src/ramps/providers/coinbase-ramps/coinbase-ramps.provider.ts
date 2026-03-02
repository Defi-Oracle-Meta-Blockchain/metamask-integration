/**
 * Coinbase Onramp and Offramp provider
 * Creates hosted widget URL sessions via Coinbase CDP
 */

import type { IOnRampProvider, IOffRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';

const COINBASE_ONRAMP_URL = 'https://pay.coinbase.com/buy/select-asset';
const COINBASE_OFFRAMP_URL = 'https://pay.coinbase.com/sell/select-asset';

export class CoinbaseRampsProvider implements IOnRampProvider, IOffRampProvider {
  readonly id = 'coinbase-ramps';
  private appId: string;

  constructor(config: { appId: string }) {
    this.appId = config.appId;
  }

  async createSession(params: OnRampSessionParams): Promise<RampSession> {
    const addrs: Record<string, string> = { [params.cryptoCurrency]: params.walletAddress };
    const search = new URLSearchParams({
      appId: this.appId,
      addresses: JSON.stringify(addrs),
      assets: params.cryptoCurrency.toUpperCase(),
      fiatCurrency: params.fiatCurrency,
      presetFiatAmount: params.amount,
    });
    if (params.chainId) search.set('network', String(params.chainId));
    if (params.redirectUrl) search.set('redirectUrl', params.redirectUrl);

    const url = `${COINBASE_ONRAMP_URL}?${search.toString()}`;
    const sessionId = `cb-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

    return {
      url,
      sessionId,
      expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      provider: this.id,
    };
  }

  async createPayoutSession(params: OffRampSessionParams): Promise<RampSession> {
    const addrs: Record<string, string> = { [params.cryptoCurrency]: params.walletAddress };
    const search = new URLSearchParams({
      appId: this.appId,
      addresses: JSON.stringify(addrs),
      assets: params.cryptoCurrency.toUpperCase(),
      fiatCurrency: params.fiatCurrency,
      presetCryptoAmount: params.amount,
    });
    if (params.chainId) search.set('network', String(params.chainId));
    if (params.redirectUrl) search.set('redirectUrl', params.redirectUrl);

    const url = `${COINBASE_OFFRAMP_URL}?${search.toString()}`;
    const sessionId = `cb-sell-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

    return {
      url,
      sessionId,
      expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      provider: this.id,
    };
  }

  getCapabilities(): ProviderCapabilities {
    return {
      id: this.id,
      name: 'Coinbase Ramps',
      onRamp: true,
      offRamp: true,
      quoteSupport: false,
      supportedChains: [1, 137, 42161, 10, 8453],
      supportedFiatCurrencies: ['usd', 'eur', 'gbp'],
      supportedCryptoCurrencies: ['eth', 'btc', 'usdc', 'usdt'],
    };
  }
}
