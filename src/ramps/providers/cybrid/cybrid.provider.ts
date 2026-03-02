/**
 * Cybrid fiat↔crypto on/off-ramp provider
 * Full embedded platform API
 * Docs: https://cybrid.xyz
 */

import type { IOnRampProvider, IOffRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';

export class CybridProvider implements IOnRampProvider, IOffRampProvider {
  readonly id = 'cybrid';
  private apiKey: string;
  private baseUrl: string;

  constructor(config: { apiKey: string; baseUrl?: string }) {
    this.apiKey = config.apiKey;
    this.baseUrl = config.baseUrl ?? 'https://api.cybrid.xyz';
  }

  async createSession(params: OnRampSessionParams): Promise<RampSession> {
    try {
      const res = await fetch(`${this.baseUrl}/api/transfer_bank_links`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          transfer_destination_address: params.walletAddress,
          asset: params.cryptoCurrency.toUpperCase(),
          amount: params.amount,
          currency: params.fiatCurrency,
          redirect_url: params.redirectUrl,
        }),
      });

      if (!res.ok) {
        const err = await res.text();
        throw new Error(`Cybrid API error: ${res.status} ${err}`);
      }

      const data = (await res.json()) as { url?: string; guid?: string };
      const url = data.url ?? `${this.baseUrl}/platform?link=${data.guid}`;
      const sessionId = `cybrid-${data.guid ?? Date.now()}`;

      return {
        url,
        sessionId,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
        provider: this.id,
      };
    } catch (err) {
      throw new Error(`Cybrid on-ramp failed: ${(err as Error).message}`);
    }
  }

  async createPayoutSession(params: OffRampSessionParams): Promise<RampSession> {
    try {
      const res = await fetch(`${this.baseUrl}/api/transfer_bank_links`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          transfer_source_address: params.walletAddress,
          asset: params.cryptoCurrency.toUpperCase(),
          amount: params.amount,
          currency: params.fiatCurrency,
          destination_account: params.destinationAccount,
          redirect_url: params.redirectUrl,
        }),
      });

      if (!res.ok) {
        const err = await res.text();
        throw new Error(`Cybrid API error: ${res.status} ${err}`);
      }

      const data = (await res.json()) as { url?: string; guid?: string };
      const url = data.url ?? `${this.baseUrl}/platform/sell?link=${data.guid}`;
      const sessionId = `cybrid-sell-${data.guid ?? Date.now()}`;

      return {
        url,
        sessionId,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
        provider: this.id,
      };
    } catch (err) {
      throw new Error(`Cybrid off-ramp failed: ${(err as Error).message}`);
    }
  }

  getCapabilities(): ProviderCapabilities {
    return {
      id: this.id,
      name: 'Cybrid',
      onRamp: true,
      offRamp: true,
      quoteSupport: false,
      supportedChains: [1, 137],
      supportedFiatCurrencies: ['usd', 'eur', 'cad'],
      supportedCryptoCurrencies: ['eth', 'btc', 'usdc', 'usdt'],
    };
  }
}
