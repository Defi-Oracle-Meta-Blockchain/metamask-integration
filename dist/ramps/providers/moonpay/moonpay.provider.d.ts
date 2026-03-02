/**
 * MoonPay on-ramp and off-ramp provider
 * Creates buy/sell URLs for the MoonPay widget
 * Docs: https://developers.moonpay.com
 */
import type { IOnRampProvider, IOffRampProvider, IRampQuoteProvider } from '../../provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampQuoteParams, RampSession, RampQuote, ProviderCapabilities } from '../../types';
export declare class MoonPayProvider implements IOnRampProvider, IOffRampProvider, IRampQuoteProvider {
    readonly id = "moonpay";
    private apiKey;
    private baseUrl;
    private sellBaseUrl;
    private apiBaseUrl;
    constructor(config: {
        apiKey: string;
        baseUrl?: string;
        sellBaseUrl?: string;
    });
    createSession(params: OnRampSessionParams): Promise<RampSession>;
    createPayoutSession(params: OffRampSessionParams): Promise<RampSession>;
    getQuote(params: RampQuoteParams): Promise<RampQuote | null>;
    getCapabilities(): ProviderCapabilities;
}
//# sourceMappingURL=moonpay.provider.d.ts.map