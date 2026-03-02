/**
 * Onramper aggregator provider
 * One API to many ramps - best-rate routing
 * Docs: https://docs.onramper.com
 */
import type { IOnRampProvider, IRampQuoteProvider } from '../../provider.interface';
import type { OnRampSessionParams, RampQuoteParams, RampSession, RampQuote, ProviderCapabilities } from '../../types';
export declare class OnramperProvider implements IOnRampProvider, IRampQuoteProvider {
    readonly id = "onramper";
    private apiKey;
    constructor(config: {
        apiKey: string;
    });
    createSession(params: OnRampSessionParams): Promise<RampSession>;
    getQuote(params: RampQuoteParams): Promise<RampQuote | null>;
    private toOnramperCryptoId;
    getCapabilities(): ProviderCapabilities;
}
//# sourceMappingURL=onramper.provider.d.ts.map