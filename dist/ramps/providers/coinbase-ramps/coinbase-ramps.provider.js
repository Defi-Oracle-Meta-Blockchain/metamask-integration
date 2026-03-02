"use strict";
/**
 * Coinbase Onramp and Offramp provider
 * Creates hosted widget URL sessions via Coinbase CDP
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.CoinbaseRampsProvider = void 0;
const COINBASE_ONRAMP_URL = 'https://pay.coinbase.com/buy/select-asset';
const COINBASE_OFFRAMP_URL = 'https://pay.coinbase.com/sell/select-asset';
class CoinbaseRampsProvider {
    constructor(config) {
        this.id = 'coinbase-ramps';
        this.appId = config.appId;
    }
    async createSession(params) {
        const addrs = { [params.cryptoCurrency]: params.walletAddress };
        const search = new URLSearchParams({
            appId: this.appId,
            addresses: JSON.stringify(addrs),
            assets: params.cryptoCurrency.toUpperCase(),
            fiatCurrency: params.fiatCurrency,
            presetFiatAmount: params.amount,
        });
        if (params.chainId)
            search.set('network', String(params.chainId));
        if (params.redirectUrl)
            search.set('redirectUrl', params.redirectUrl);
        const url = `${COINBASE_ONRAMP_URL}?${search.toString()}`;
        const sessionId = `cb-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
        return {
            url,
            sessionId,
            expiresAt: new Date(Date.now() + 30 * 60 * 1000),
            provider: this.id,
        };
    }
    async createPayoutSession(params) {
        const addrs = { [params.cryptoCurrency]: params.walletAddress };
        const search = new URLSearchParams({
            appId: this.appId,
            addresses: JSON.stringify(addrs),
            assets: params.cryptoCurrency.toUpperCase(),
            fiatCurrency: params.fiatCurrency,
            presetCryptoAmount: params.amount,
        });
        if (params.chainId)
            search.set('network', String(params.chainId));
        if (params.redirectUrl)
            search.set('redirectUrl', params.redirectUrl);
        const url = `${COINBASE_OFFRAMP_URL}?${search.toString()}`;
        const sessionId = `cb-sell-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
        return {
            url,
            sessionId,
            expiresAt: new Date(Date.now() + 30 * 60 * 1000),
            provider: this.id,
        };
    }
    getCapabilities() {
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
exports.CoinbaseRampsProvider = CoinbaseRampsProvider;
//# sourceMappingURL=coinbase-ramps.provider.js.map