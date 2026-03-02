/**
 * Stripe Crypto Onramp provider (on-ramp only)
 * Creates on-ramp sessions via Stripe API
 */

import type { IOnRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, RampSession, ProviderCapabilities } from '../../types';

export class StripeCryptoProvider implements IOnRampProvider {
  readonly id = 'stripe-crypto';
  private apiKey: string;

  constructor(config: { apiKey: string }) {
    this.apiKey = config.apiKey;
  }

  async createSession(params: OnRampSessionParams): Promise<RampSession> {
    try {
      const body = new URLSearchParams({
        'transaction_details[destination_wallet_address]': params.walletAddress,
        'transaction_details[destination_network]': this.chainToNetwork(params.chainId),
        'transaction_details[destination_currency]': params.cryptoCurrency.toLowerCase(),
        'transaction_details[destination_currency_amount]': params.amount,
      });
      if (params.email) body.set('customer_information[email]', params.email);

      const res = await fetch('https://api.stripe.com/v1/crypto/onramp_sessions', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body.toString(),
      });

      if (!res.ok) {
        const err = await res.text();
        throw new Error(`Stripe API error: ${res.status} ${err}`);
      }

      const data = (await res.json()) as { client_secret?: string };
      const url = `https://crypto.onramp.stripe.com?client_secret=${data.client_secret ?? ''}`;
      const sessionId = `stripe-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

      return {
        url,
        sessionId,
        expiresAt: new Date(Date.now() + 60 * 60 * 1000),
        provider: this.id,
      };
    } catch (err) {
      throw new Error(`Stripe Crypto on-ramp failed: ${(err as Error).message}`);
    }
  }

  private chainToNetwork(chainId?: number): string {
    const map: Record<number, string> = {
      1: 'ethereum',
      137: 'polygon',
      42161: 'arbitrum',
      10: 'optimism',
      8453: 'base',
    };
    return chainId ? (map[chainId] ?? 'ethereum') : 'ethereum';
  }

  getCapabilities(): ProviderCapabilities {
    return {
      id: this.id,
      name: 'Stripe Crypto',
      onRamp: true,
      offRamp: false,
      quoteSupport: false,
      supportedChains: [1, 137, 42161, 10, 8453],
      supportedFiatCurrencies: ['usd'],
      supportedCryptoCurrencies: ['eth', 'usdc', 'usdt'],
    };
  }
}
