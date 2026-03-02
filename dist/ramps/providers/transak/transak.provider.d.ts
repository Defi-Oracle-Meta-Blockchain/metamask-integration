/**
 * Transak on-ramp and off-ramp provider
 * Docs: https://docs.transak.com
 */
import type { IOnRampProvider, IOffRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';
export declare class TransakProvider implements IOnRampProvider, IOffRampProvider {
    readonly id = "transak";
    private apiKey;
    private baseUrl;
    constructor(config: {
        apiKey: string;
        baseUrl?: string;
    });
    createSession(params: OnRampSessionParams): Promise<RampSession>;
    createPayoutSession(params: OffRampSessionParams): Promise<RampSession>;
    private chainToNetwork;
    getCapabilities(): ProviderCapabilities;
}
//# sourceMappingURL=transak.provider.d.ts.map