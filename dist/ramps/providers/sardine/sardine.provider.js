"use strict";
/**
 * Sardine Payments Onramp provider (on-ramp focused)
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.SardineProvider = void 0;
class SardineProvider {
    constructor(config) {
        this.id = 'sardine';
        this.baseUrl = 'https://api.sardine.ai';
        this.apiKey = config.apiKey;
        if (config.baseUrl)
            this.baseUrl = config.baseUrl;
    }
    async createSession(params) {
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
        if (!res.ok)
            throw new Error('Sardine API error: ' + res.status);
        const data = (await res.json());
        const url = data.checkout_url ?? this.baseUrl + '/checkout/' + data.order_id;
        const sessionId = 'sardine-' + (data.order_id ?? Date.now());
        return { url, sessionId, expiresAt: new Date(Date.now() + 3600000), provider: this.id };
    }
    getCapabilities() {
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
exports.SardineProvider = SardineProvider;
//# sourceMappingURL=sardine.provider.js.map