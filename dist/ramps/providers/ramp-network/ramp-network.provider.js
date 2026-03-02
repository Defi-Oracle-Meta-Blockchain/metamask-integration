"use strict";
/**
 * Ramp Network on-ramp and off-ramp provider
 * Creates URLs for the Ramp Instant widget
 * Docs: https://docs.rampnetwork.com
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.RampNetworkProvider = void 0;
const MAP_CRYPTO = {
    eth: 'ETH',
    ethereum: 'ETH',
    btc: 'BTC',
    bitcoin: 'BTC',
    usdc: 'USDC',
    usdt: 'USDT',
    matic: 'MATIC',
    polygon: 'POLYGON_MATIC',
};
function toRampAsset(crypto, chainId) {
    const lower = crypto.toLowerCase();
    if (MAP_CRYPTO[lower])
        return MAP_CRYPTO[lower];
    return crypto.toUpperCase();
}
class RampNetworkProvider {
    constructor(config) {
        this.id = 'ramp-network';
        this.baseUrl = 'https://ri-widget-staging.firebaseapp.com';
        this.hostApiKey = config.hostApiKey;
        if (config.baseUrl)
            this.baseUrl = config.baseUrl;
    }
    async createSession(params) {
        const swapAsset = toRampAsset(params.cryptoCurrency, params.chainId);
        const search = new URLSearchParams({
            hostApiKey: this.hostApiKey,
            userAddress: params.walletAddress,
            swapAsset,
            swapAmount: params.amount,
            fiatCurrency: params.fiatCurrency,
            fiatValue: params.amount,
        });
        if (params.chainId)
            search.set('network', String(params.chainId));
        if (params.redirectUrl)
            search.set('finalUrl', params.redirectUrl);
        if (params.email)
            search.set('userEmailAddress', params.email);
        const url = `${this.baseUrl}/?${search.toString()}`;
        const sessionId = `rn-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
        return {
            url,
            sessionId,
            expiresAt: new Date(Date.now() + 30 * 60 * 1000),
            provider: this.id,
        };
    }
    async createPayoutSession(params) {
        const swapAsset = toRampAsset(params.cryptoCurrency, params.chainId);
        const search = new URLSearchParams({
            hostApiKey: this.hostApiKey,
            userAddress: params.walletAddress,
            swapAsset,
            swapAmount: params.amount,
            fiatCurrency: params.fiatCurrency,
            fiatValue: params.amount,
        });
        if (params.chainId)
            search.set('network', String(params.chainId));
        if (params.redirectUrl)
            search.set('finalUrl', params.redirectUrl);
        const url = `${this.baseUrl}/sell/?${search.toString()}`;
        const sessionId = `rn-sell-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
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
            name: 'Ramp Network',
            onRamp: true,
            offRamp: true,
            quoteSupport: false,
            supportedChains: [1, 137, 56, 42161, 10, 8453],
            supportedFiatCurrencies: ['usd', 'eur', 'gbp', 'pln'],
            supportedCryptoCurrencies: ['eth', 'btc', 'usdc', 'usdt', 'matic'],
        };
    }
}
exports.RampNetworkProvider = RampNetworkProvider;
//# sourceMappingURL=ramp-network.provider.js.map