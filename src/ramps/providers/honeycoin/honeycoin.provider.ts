/**
 * HoneyCoin Offramps provider (off-ramp focused)
 * Stablecoins to bank/mobile money - docs.honeycoin.app
 */

import type { IOffRampProvider } from '../../provider.interface';
import type { OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';

export class HoneyCoinProvider implements IOffRampProvider {
  readonly id = 'honeycoin';
  private apiKey: string;
  private baseUrl = 'https://api.honeycoin.app';

  constructor(config: { apiKey: string; baseUrl?: string }) {
    this.apiKey = config.apiKey;
    if (config.baseUrl) this.baseUrl = config.baseUrl;
  }

  async createPayoutSession(params: OffRampSessionParams): Promise<RampSession> {
    try {
      const res = await fetch(`${this.baseUrl}/v1/offramp/sessions`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          source_address: params.walletAddress,
          amount: params.amount,
          asset: params.cryptoCurrency,
          fiat_currency: params.fiatCurrency,
          destination_account: params.destinationAccount,
          chain_id: params.chainId ?? 1,
          redirect_url: params.redirectUrl,
        }),
      });

      if (!res.ok) {
        const err = await res.text();
        throw new Error(`HoneyCoin API error: ${res.status} ${err}`);
      }

      const data = (await res.json()) as { checkout_url?: string; session_id?: string };
      const url = data.checkout_url ?? `${this.baseUrl}/checkout/${data.session_id}`;
      const sessionId = `honeycoin-${data.session_id ?? Date.now()}`;

      return {
        url,
        sessionId,
        expiresAt: new Date(Date.now() + 60 * 60 * 1000),
        provider: this.id,
      };
    } catch (err) {
      throw new Error(`HoneyCoin off-ramp failed: ${(err as Error).message}`);
    }
  }

  getCapabilities(): ProviderCapabilities {
    return {
      id: this.id,
      name: 'HoneyCoin',
      onRamp: false,
      offRamp: true,
      quoteSupport: false,
      supportedChains: [1, 137],
      supportedFiatCurrencies: ['usd', 'eur'],
      supportedCryptoCurrencies: ['usdc', 'usdt'],
    };
  }
}
