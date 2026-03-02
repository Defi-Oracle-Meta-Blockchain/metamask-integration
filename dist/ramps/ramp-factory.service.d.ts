/**
 * Ramp factory service - creates and selects ramp providers
 */
import type { OnRampSessionParams, OffRampSessionParams, RampQuoteParams, RampSession, RampQuote, ProviderCapabilities } from './types';
export type RampProviderId = 'moonpay' | 'ramp-network' | 'onramper' | 'transak' | 'banxa' | 'coinbase-ramps' | 'stripe-crypto' | 'cybrid' | 'sardine' | 'honeycoin';
export declare class RampFactoryService {
    private onRampProviders;
    private offRampProviders;
    private quoteProviders;
    private defaultOnRamp;
    private defaultOffRamp;
    constructor();
    private registerProviders;
    createOnRampSession(params: OnRampSessionParams, providerId?: RampProviderId): Promise<RampSession>;
    createOffRampSession(params: OffRampSessionParams, providerId?: RampProviderId): Promise<RampSession>;
    getQuote(params: RampQuoteParams, providerId?: RampProviderId): Promise<RampQuote | null>;
    getProviders(): ProviderCapabilities[];
    setDefaultOnRamp(id: RampProviderId): void;
    setDefaultOffRamp(id: RampProviderId): void;
}
export declare const rampFactoryService: RampFactoryService;
//# sourceMappingURL=ramp-factory.service.d.ts.map