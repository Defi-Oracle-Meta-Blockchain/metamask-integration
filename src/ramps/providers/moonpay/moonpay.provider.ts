/**
 * MoonPay on-ramp and off-ramp provider
 * Creates buy/sell URLs for the MoonPay widget
 * Docs: https://developers.moonpay.com
 */

import type { IOnRampProvider, IOffRampProvider, IRampQuoteProvider } from '../../provider.interface';
import type {
  OnRampSessionParams,
  OffRampSessionParams,
  RampQuoteParams,
  RampSession,
  RampQuote,
  ProviderCapabilities,
} from '../../types';

const MAP_CRYPTO: Record<string, string> = {
  eth: 'eth',
  ethereum: 'eth',
  btc: 'btc',
  bitcoin: 'btc',
  usdc: 'usdc_ethereum',
  usdt: 'usdt_ethereum',
  matic: 'matic_polygon',
  polygon: 'matic_polygon',
  bnb: 'bnb_bsc',
};

function toMoonPayCryptoCode(crypto: string, chainId?: number): string {
  const lower = crypto.toLowerCase();
  if (MAP_CRYPTO[lower]) return MAP_CRYPTO[lower];
  if (chainId === 1) return `${lower}_ethereum`;
  if (chainId === 137) return `${lower}_polygon`;
  if (chainId === 56) return `${lower}_bsc`;
  return lower;
}

export class MoonPayProvider implements IOnRampProvider, IOffRampProvider, IRampQuoteProvider {
  readonly id = 'moonpay';
  private apiKey: string;
  private baseUrl = 'https://buy.moonpay.com';
  private sellBaseUrl = 'https://sell.moonpay.com';
  private apiBaseUrl = 'https://api.moonpay.com';

  constructor(config: { apiKey: string; baseUrl?: string; sellBaseUrl?: string }) {
    this.apiKey = config.apiKey;
    if (config.baseUrl) this.baseUrl = config.baseUrl;
    if (config.sellBaseUrl) this.sellBaseUrl = config.sellBaseUrl;
  }

  async createSession(params: OnRampSessionParams): Promise<RampSession> {
    const currencyCode = toMoonPayCryptoCode(params.cryptoCurrency, params.chainId);
    const search = new URLSearchParams({
      apiKey: this.apiKey,
      walletAddress: params.walletAddress,
      currencyCode,
      baseCurrencyCode: params.fiatCurrency.toLowerCase(),
      baseCurrencyAmount: params.amount,
    });
    if (params.redirectUrl) search.set('redirectURL', params.redirectUrl);
    if (params.email) search.set('email', params.email);

    const url = `${this.baseUrl}?${search.toString()}`;
    const sessionId = `mp-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

    return {
      url,
      sessionId,
      expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      provider: this.id,
    };
  }

  async createPayoutSession(params: OffRampSessionParams): Promise<RampSession> {
    const currencyCode = toMoonPayCryptoCode(params.cryptoCurrency, params.chainId);
    const search = new URLSearchParams({
      apiKey: this.apiKey,
      walletAddress: params.walletAddress,
      currencyCode,
      baseCurrencyCode: params.fiatCurrency.toLowerCase(),
      baseCurrencyAmount: params.amount,
    });
    if (params.redirectUrl) search.set('redirectURL', params.redirectUrl);
    if (params.destinationAccount) search.set('payoutAddress', params.destinationAccount);

    const url = `${this.sellBaseUrl}?${search.toString()}`;
    const sessionId = `mp-sell-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;

    return {
      url,
      sessionId,
      expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      provider: this.id,
    };
  }

  async getQuote(params: RampQuoteParams): Promise<RampQuote | null> {
    try {
      const currencyCode = toMoonPayCryptoCode(params.cryptoCurrency, params.chainId);
      const url = `${this.apiBaseUrl}/v3/currencies/${currencyCode}/buy_quote?apiKey=${this.apiKey}&baseCurrencyAmount=${params.amount}&baseCurrencyCode=${params.fiatCurrency.toLowerCase()}`;
      const res = await fetch(url);
      if (!res.ok) return null;
      const data = (await res.json()) as { quoteCurrencyAmount?: number; totalAmount?: number; totalFee?: number };
      const estimatedAmount = params.side === 'buy'
        ? String(data.quoteCurrencyAmount ?? 0)
        : params.amount;
      const fees = String(data.totalFee ?? 0);

      return {
        rate: data.quoteCurrencyAmount ? String(parseFloat(params.amount) / data.quoteCurrencyAmount) : '0',
        fees,
        estimatedAmount,
        provider: this.id,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000),
      };
    } catch {
      return null;
    }
  }

  getCapabilities(): ProviderCapabilities {
    return {
      id: this.id,
      name: 'MoonPay',
      onRamp: true,
      offRamp: true,
      quoteSupport: true,
      supportedChains: [1, 137, 56, 42161, 10],
      supportedFiatCurrencies: ['usd', 'eur', 'gbp'],
      supportedCryptoCurrencies: ['eth', 'btc', 'usdc', 'usdt', 'matic', 'bnb'],
    };
  }
}
