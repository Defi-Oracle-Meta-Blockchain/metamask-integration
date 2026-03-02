"use strict";
/**
 * Ramp factory service - creates and selects ramp providers
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.rampFactoryService = exports.RampFactoryService = void 0;
const moonpay_1 = require("./providers/moonpay");
const ramp_network_1 = require("./providers/ramp-network");
const onramper_1 = require("./providers/onramper");
const transak_1 = require("./providers/transak");
const banxa_1 = require("./providers/banxa");
const coinbase_ramps_1 = require("./providers/coinbase-ramps");
const stripe_crypto_1 = require("./providers/stripe-crypto");
const cybrid_1 = require("./providers/cybrid");
const sardine_1 = require("./providers/sardine");
const honeycoin_1 = require("./providers/honeycoin");
const DEFAULT_ON_RAMP_PROVIDER = 'onramper';
const DEFAULT_OFF_RAMP_PROVIDER = 'moonpay';
class RampFactoryService {
    constructor() {
        this.onRampProviders = new Map();
        this.offRampProviders = new Map();
        this.quoteProviders = new Map();
        this.defaultOnRamp = DEFAULT_ON_RAMP_PROVIDER;
        this.defaultOffRamp = DEFAULT_OFF_RAMP_PROVIDER;
        this.registerProviders();
    }
    registerProviders() {
        const moonpayKey = process.env.MOONPAY_API_KEY;
        if (moonpayKey) {
            const moonpay = new moonpay_1.MoonPayProvider({ apiKey: moonpayKey });
            this.onRampProviders.set('moonpay', moonpay);
            this.offRampProviders.set('moonpay', moonpay);
            this.quoteProviders.set('moonpay', moonpay);
        }
        const rampKey = process.env.RAMP_NETWORK_API_KEY;
        if (rampKey) {
            const ramp = new ramp_network_1.RampNetworkProvider({ hostApiKey: rampKey });
            this.onRampProviders.set('ramp-network', ramp);
            this.offRampProviders.set('ramp-network', ramp);
        }
        const onramperKey = process.env.ONRAMPER_API_KEY;
        if (onramperKey) {
            const onramper = new onramper_1.OnramperProvider({ apiKey: onramperKey });
            this.onRampProviders.set('onramper', onramper);
            this.quoteProviders.set('onramper', onramper);
        }
        const transakKey = process.env.TRANSAK_API_KEY;
        if (transakKey) {
            const transak = new transak_1.TransakProvider({ apiKey: transakKey });
            this.onRampProviders.set('transak', transak);
            this.offRampProviders.set('transak', transak);
        }
        const banxaKey = process.env.BANXA_API_KEY;
        if (banxaKey) {
            const banxa = new banxa_1.BanxaProvider({ apiKey: banxaKey });
            this.onRampProviders.set('banxa', banxa);
            this.offRampProviders.set('banxa', banxa);
        }
        const coinbaseAppId = process.env.COINBASE_CLIENT_ID;
        if (coinbaseAppId) {
            const coinbase = new coinbase_ramps_1.CoinbaseRampsProvider({ appId: coinbaseAppId });
            this.onRampProviders.set('coinbase-ramps', coinbase);
            this.offRampProviders.set('coinbase-ramps', coinbase);
        }
        const stripeKey = process.env.STRIPE_SECRET_KEY;
        if (stripeKey) {
            const stripe = new stripe_crypto_1.StripeCryptoProvider({ apiKey: stripeKey });
            this.onRampProviders.set('stripe-crypto', stripe);
        }
        const cybridKey = process.env.CYBRID_API_KEY;
        if (cybridKey) {
            const cybrid = new cybrid_1.CybridProvider({ apiKey: cybridKey });
            this.onRampProviders.set('cybrid', cybrid);
            this.offRampProviders.set('cybrid', cybrid);
        }
        const sardineKey = process.env.SARDINE_API_KEY;
        if (sardineKey) {
            const sardine = new sardine_1.SardineProvider({ apiKey: sardineKey });
            this.onRampProviders.set('sardine', sardine);
        }
        const honeycoinKey = process.env.HONEYCOIN_API_KEY;
        if (honeycoinKey) {
            const honeycoin = new honeycoin_1.HoneyCoinProvider({ apiKey: honeycoinKey });
            this.offRampProviders.set('honeycoin', honeycoin);
        }
    }
    async createOnRampSession(params, providerId) {
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
    async createOffRampSession(params, providerId) {
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
    async getQuote(params, providerId) {
        const providers = providerId
            ? [this.quoteProviders.get(providerId)].filter((p) => !!p)
            : Array.from(this.quoteProviders.values());
        for (const provider of providers) {
            const quote = await provider.getQuote(params);
            if (quote)
                return quote;
        }
        return null;
    }
    getProviders() {
        const seen = new Set();
        const caps = [];
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
    setDefaultOnRamp(id) {
        this.defaultOnRamp = id;
    }
    setDefaultOffRamp(id) {
        this.defaultOffRamp = id;
    }
}
exports.RampFactoryService = RampFactoryService;
exports.rampFactoryService = new RampFactoryService();
//# sourceMappingURL=ramp-factory.service.js.map