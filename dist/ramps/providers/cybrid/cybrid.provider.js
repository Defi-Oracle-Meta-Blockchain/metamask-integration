"use strict";
/**
 * Cybrid fiat↔crypto on/off-ramp provider
 * Full embedded platform API
 * Docs: https://cybrid.xyz
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.CybridProvider = void 0;
class CybridProvider {
    constructor(config) {
        this.id = 'cybrid';
        this.apiKey = config.apiKey;
        this.baseUrl = config.baseUrl ?? 'https://api.cybrid.xyz';
    }
    async createSession(params) {
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
            const data = (await res.json());
            const url = data.url ?? `${this.baseUrl}/platform?link=${data.guid}`;
            const sessionId = `cybrid-${data.guid ?? Date.now()}`;
            return {
                url,
                sessionId,
                expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
                provider: this.id,
            };
        }
        catch (err) {
            throw new Error(`Cybrid on-ramp failed: ${err.message}`);
        }
    }
    async createPayoutSession(params) {
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
            const data = (await res.json());
            const url = data.url ?? `${this.baseUrl}/platform/sell?link=${data.guid}`;
            const sessionId = `cybrid-sell-${data.guid ?? Date.now()}`;
            return {
                url,
                sessionId,
                expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
                provider: this.id,
            };
        }
        catch (err) {
            throw new Error(`Cybrid off-ramp failed: ${err.message}`);
        }
    }
    getCapabilities() {
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
exports.CybridProvider = CybridProvider;
//# sourceMappingURL=cybrid.provider.js.map