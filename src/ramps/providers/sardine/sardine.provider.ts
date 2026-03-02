/**
 * Sardine Payments Onramp provider (on-ramp focused)
 */

import type { IOnRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, RampSession, ProviderCapabilities } from '../../types';

export class SardineProvider implements IOnRampProvider {
  readonly id = 'sardine';
  private apiKey: string;
  private baseUrl = 'https://api.sardine.ai';

  constructor(config: { apiKey: string; baseUrl?: string }) {
    this.apiKey = config.apiKey;
    if (config.baseUrl) this.baseUrl = config.baseUrl;
  }

  async createSession(params: OnRampSessionParams): Promise<RampSession> {
    const res = await fetch(this.baseUrl + '/v1/onramp/orders', {
      method: 'POST',
      headers: { Authorization: 'Bearer ' + this.apiKey, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        source_amount: params.amount,
        source_currency: params.fiatCurrency,
        destination_currency: params.cryptoCurrency,
        destination_address: params.walletAddress,
        chain_id: params.chainId ?? 1,
        redirect_url: params.redirectUrl,
      }),
    });
    if (!res.ok) throw new Error('Sardine API error: ' + res.status);
    const data = (await res.json()) as { checkout_url?: string; order_id?: string };
    const url = data.checkout_url ?? this.baseUrl + '/checkout/' + data.order_id;
    const sessionId = 'sardine-' + (data.order_id ?? Date.now());
    return { url, sessionId, expiresAt: new Date(Date.now() + 3600000), provider: this.id };
  }

  getCapabilities(): ProviderCapabilities {
    return {
      id: this.id,
      name: 'Sardine Payments',
      onRamp: true,
      offRamp: false,
      quoteSupport: false,
      supportedChains: [1, 137, 42161],
      supportedFiatCurrencies: ['usd'],
      supportedCryptoCurrencies: ['eth', 'usdc', 'usdt'],
    };
  }
}
