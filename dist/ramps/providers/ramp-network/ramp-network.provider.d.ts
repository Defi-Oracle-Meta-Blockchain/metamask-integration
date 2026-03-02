/**
 * Ramp Network on-ramp and off-ramp provider
 * Creates URLs for the Ramp Instant widget
 * Docs: https://docs.rampnetwork.com
 */
import type { IOnRampProvider, IOffRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';
export declare class RampNetworkProvider implements IOnRampProvider, IOffRampProvider {
    readonly id = "ramp-network";
    private hostApiKey;
    private baseUrl;
    constructor(config: {
        hostApiKey: string;
        baseUrl?: string;
    });
    createSession(params: OnRampSessionParams): Promise<RampSession>;
    createPayoutSession(params: OffRampSessionParams): Promise<RampSession>;
    getCapabilities(): ProviderCapabilities;
}
//# sourceMappingURL=ramp-network.provider.d.ts.map