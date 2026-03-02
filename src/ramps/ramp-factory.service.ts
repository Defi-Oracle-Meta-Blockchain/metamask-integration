/**
 * Ramp factory service - creates and selects ramp providers
 */

import type { IOnRampProvider, IOffRampProvider, IRampQuoteProvider } from './provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampQuoteParams, RampSession, RampQuote, ProviderCapabilities } from './types';
import { MoonPayProvider } from './providers/moonpay';
import { RampNetworkProvider } from './providers/ramp-network';
import { OnramperProvider } from './providers/onramper';
import { TransakProvider } from './providers/transak';
import { BanxaProvider } from './providers/banxa';
import { CoinbaseRampsProvider } from './providers/coinbase-ramps';
import { StripeCryptoProvider } from './providers/stripe-crypto';
import { CybridProvider } from './providers/cybrid';
import { SardineProvider } from './providers/sardine';
import { HoneyCoinProvider } from './providers/honeycoin';

export type RampProviderId =
  | 'moonpay'
  | 'ramp-network'
  | 'onramper'
  | 'transak'
  | 'banxa'
  | 'coinbase-ramps'
  | 'stripe-crypto'
  | 'cybrid'
  | 'sardine'
  | 'honeycoin';

const DEFAULT_ON_RAMP_PROVIDER: RampProviderId = 'onramper';
const DEFAULT_OFF_RAMP_PROVIDER: RampProviderId = 'moonpay';

export class RampFactoryService {
  private onRampProviders: Map<string, IOnRampProvider> = new Map();
  private offRampProviders: Map<string, IOffRampProvider> = new Map();
  private quoteProviders: Map<string, IRampQuoteProvider> = new Map();
  private defaultOnRamp: RampProviderId = DEFAULT_ON_RAMP_PROVIDER;
  private defaultOffRamp: RampProviderId = DEFAULT_OFF_RAMP_PROVIDER;

  constructor() {
    this.registerProviders();
  }

  private registerProviders(): void {
    const moonpayKey = process.env.MOONPAY_API_KEY;
    if (moonpayKey) {
      const moonpay = new MoonPayProvider({ apiKey: moonpayKey });
      this.onRampProviders.set('moonpay', moonpay);
      this.offRampProviders.set('moonpay', moonpay);
      this.quoteProviders.set('moonpay', moonpay);
    }

    const rampKey = process.env.RAMP_NETWORK_API_KEY;
    if (rampKey) {
      const ramp = new RampNetworkProvider({ hostApiKey: rampKey });
      this.onRampProviders.set('ramp-network', ramp);
      this.offRampProviders.set('ramp-network', ramp);
    }

    const onramperKey = process.env.ONRAMPER_API_KEY;
    if (onramperKey) {
      const onramper = new OnramperProvider({ apiKey: onramperKey });
      this.onRampProviders.set('onramper', onramper);
      this.quoteProviders.set('onramper', onramper);
    }

    const transakKey = process.env.TRANSAK_API_KEY;
    if (transakKey) {
      const transak = new TransakProvider({ apiKey: transakKey });
      this.onRampProviders.set('transak', transak);
      this.offRampProviders.set('transak', transak);
    }

    const banxaKey = process.env.BANXA_API_KEY;
    if (banxaKey) {
      const banxa = new BanxaProvider({ apiKey: banxaKey });
      this.onRampProviders.set('banxa', banxa);
      this.offRampProviders.set('banxa', banxa);
    }

    const coinbaseAppId = process.env.COINBASE_CLIENT_ID;
    if (coinbaseAppId) {
      const coinbase = new CoinbaseRampsProvider({ appId: coinbaseAppId });
      this.onRampProviders.set('coinbase-ramps', coinbase);
      this.offRampProviders.set('coinbase-ramps', coinbase);
    }

    const stripeKey = process.env.STRIPE_SECRET_KEY;
    if (stripeKey) {
      const stripe = new StripeCryptoProvider({ apiKey: stripeKey });
      this.onRampProviders.set('stripe-crypto', stripe);
    }

    const cybridKey = process.env.CYBRID_API_KEY;
    if (cybridKey) {
      const cybrid = new CybridProvider({ apiKey: cybridKey });
      this.onRampProviders.set('cybrid', cybrid);
      this.offRampProviders.set('cybrid', cybrid);
    }

    const sardineKey = process.env.SARDINE_API_KEY;
    if (sardineKey) {
      const sardine = new SardineProvider({ apiKey: sardineKey });
      this.onRampProviders.set('sardine', sardine);
    }

    const honeycoinKey = process.env.HONEYCOIN_API_KEY;
    if (honeycoinKey) {
      const honeycoin = new HoneyCoinProvider({ apiKey: honeycoinKey });
      this.offRampProviders.set('honeycoin', honeycoin);
    }
  }

  async createOnRampSession(
    params: OnRampSessionParams,
    providerId?: RampProviderId
  ): Promise<RampSession> {
    const id = providerId ?? this.defaultOnRamp;
    const provider = this.onRampProviders.get(id);
    if (!provider) {
      const fallback = this.onRampProviders.get(DEFAULT_ON_RAMP_PROVIDER)
        ?? Array.from(this.onRampProviders.values())[0];
      if (!fallback) {
        throw new Error(`No on-ramp provider configured. Set MOONPAY_API_KEY, RAMP_NETWORK_API_KEY, or ONRAMPER_API_KEY`);
      }
      return fallback.createSession(params);
    }
    return provider.createSession(params);
  }

  async createOffRampSession(
    params: OffRampSessionParams,
    providerId?: RampProviderId
  ): Promise<RampSession> {
    const id = providerId ?? this.defaultOffRamp;
    const provider = this.offRampProviders.get(id);
    if (!provider) {
      const fallback = this.offRampProviders.get(DEFAULT_OFF_RAMP_PROVIDER)
        ?? Array.from(this.offRampProviders.values())[0];
      if (!fallback) {
        throw new Error(`No off-ramp provider configured. Set MOONPAY_API_KEY or RAMP_NETWORK_API_KEY`);
      }
      return fallback.createPayoutSession(params);
    }
    return provider.createPayoutSession(params);
  }

  async getQuote(params: RampQuoteParams, providerId?: RampProviderId): Promise<RampQuote | null> {
    const providers = providerId
      ? [this.quoteProviders.get(providerId)].filter((p): p is IRampQuoteProvider => !!p)
      : Array.from(this.quoteProviders.values());

    for (const provider of providers) {
      const quote = await provider.getQuote(params);
      if (quote) return quote;
    }
    return null;
  }

  getProviders(): ProviderCapabilities[] {
    const seen = new Set<string>();
    const caps: ProviderCapabilities[] = [];

    for (const p of this.onRampProviders.values()) {
      const c = p.getCapabilities();
      if (!seen.has(c.id)) {
        seen.add(c.id);
        caps.push(c);
      }
    }
    for (const p of this.offRampProviders.values()) {
      const c = p.getCapabilities();
      if (!seen.has(c.id)) {
        seen.add(c.id);
        caps.push(c);
      }
    }
    return caps;
  }

  setDefaultOnRamp(id: RampProviderId): void {
    this.defaultOnRamp = id;
  }

  setDefaultOffRamp(id: RampProviderId): void {
    this.defaultOffRamp = id;
  }
}

export const rampFactoryService = new RampFactoryService();
