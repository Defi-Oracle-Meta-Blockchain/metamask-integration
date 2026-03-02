/**
 * Onramper aggregator provider
 * One API to many ramps - best-rate routing
 * Docs: https://docs.onramper.com
 */

import type { IOnRampProvider, IRampQuoteProvider } from '../../provider.interface';
import type {
  OnRampSessionParams,
  RampQuoteParams,
  RampSession,
  RampQuote,
  ProviderCapabilities,
} from '../../types';

const ONRAMPER_API = 'https://api.onramper.com';

export class OnramperProvider implements IOnRampProvider, IRampQuoteProvider {
  readonly id = 'onramper';
  private apiKey: string;

  constructor(config: { apiKey: string }) {
    this.apiKey = config.apiKey;
  }

  async createSession(params: OnRampSessionParams): Promise<RampSession> {
    const cryptoId = this.toOnramperCryptoId(params.cryptoCurrency, params.chainId);
    const fiatId = params.fiatCurrency.toUpperCase();
    const search = new URLSearchParams({
      apiKey: this.apiKey,
      mode: 'buy',
      onlyCryptos: cryptoId,
      onlyFiats: fiatId,
      defaultCrypto: cryptoId,
      defaultFiat: fiatId,
      defaultAmount: params.amount,
      wallets: `${params.cryptoCurrency}:${params.walletAddress}`,
    });
    if (params.chainId) search.set('themeName', 'default');

    const url = `https://buy.onramper.com?${search.toString()}`;
    const sessionId = `onr-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

    return {
      url,
      sessionId,
      expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      provider: this.id,
    };
  }

  async getQuote(params: RampQuoteParams): Promise<RampQuote | null> {
    try {
      const cryptoId = this.toOnramperCryptoId(params.cryptoCurrency, params.chainId);
      const fiatId = params.fiatCurrency.toUpperCase();
      const amountType = params.side === 'buy' ? 'fiat' : 'crypto';
      const amount = params.amount;

      const url = `${ONRAMPER_API}/quotes/${cryptoId}/${fiatId}/${amount}/${amountType}?apiKey=${this.apiKey}`;
      const res = await fetch(url);
      if (!res.ok) return null;

      const data = (await res.json()) as {
        crypto?: { amount?: number; symbol?: string };
        fiat?: { amount?: number; symbol?: string };
        totalFee?: number;
        providers?: Array<{ provider?: string }>;
      };

      const estimatedAmount =
        params.side === 'buy'
          ? String(data.crypto?.amount ?? 0)
          : String(data.fiat?.amount ?? 0);
      const fees = String(data.totalFee ?? 0);
      const rate =
        data.crypto?.amount && data.fiat?.amount
          ? String(data.fiat.amount / data.crypto.amount)
          : '0';

      return {
        rate,
        fees,
        estimatedAmount,
        provider: this.id,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000),
      };
    } catch {
      return null;
    }
  }

  private toOnramperCryptoId(crypto: string, chainId?: number): string {
    const lower = crypto.toLowerCase();
    const map: Record<string, string> = {
      eth: 'ETH',
      ethereum: 'ETH',
      btc: 'BTC',
      bitcoin: 'BTC',
      usdc: 'USDC',
      usdt: 'USDT',
      matic: 'MATIC',
      polygon: 'MATIC',
      bnb: 'BNB',
    };
    const base = map[lower] ?? crypto.toUpperCase();
    if (chainId === 1) return `${base}_ETH`;
    if (chainId === 137) return `${base}_MATIC`;
    if (chainId === 56) return `${base}_BSC`;
    if (chainId === 42161) return `${base}_ARBITRUM`;
    return base;
  }

  getCapabilities(): ProviderCapabilities {
    return {
      id: this.id,
      name: 'Onramper',
      onRamp: true,
      offRamp: false,
      quoteSupport: true,
      supportedChains: [1, 137, 56, 42161, 10, 8453, 43114],
      supportedFiatCurrencies: ['USD', 'EUR', 'GBP', 'PLN', 'BRL'],
      supportedCryptoCurrencies: ['eth', 'btc', 'usdc', 'usdt', 'matic', 'bnb', 'avax'],
    };
  }
}
