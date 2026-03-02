"use strict";
/**
 * HoneyCoin Offramps provider (off-ramp focused)
 * Stablecoins to bank/mobile money - docs.honeycoin.app
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.HoneyCoinProvider = void 0;
class HoneyCoinProvider {
    constructor(config) {
        this.id = 'honeycoin';
        this.baseUrl = 'https://api.honeycoin.app';
        this.apiKey = config.apiKey;
        if (config.baseUrl)
            this.baseUrl = config.baseUrl;
    }
    async createPayoutSession(params) {
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
            const data = (await res.json());
            const url = data.checkout_url ?? `${this.baseUrl}/checkout/${data.session_id}`;
            const sessionId = `honeycoin-${data.session_id ?? Date.now()}`;
            return {
                url,
                sessionId,
                expiresAt: new Date(Date.now() + 60 * 60 * 1000),
                provider: this.id,
            };
        }
        catch (err) {
            throw new Error(`HoneyCoin off-ramp failed: ${err.message}`);
        }
    }
    getCapabilities() {
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
exports.HoneyCoinProvider = HoneyCoinProvider;
//# sourceMappingURL=honeycoin.provider.js.map