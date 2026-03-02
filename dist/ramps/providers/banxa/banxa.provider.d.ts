/**
 * Banxa on-ramp and off-ramp provider
 * Docs: https://docs.banxa.com
 */
import type { IOnRampProvider, IOffRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';
export declare class BanxaProvider implements IOnRampProvider, IOffRampProvider {
    readonly id = "banxa";
    private apiKey;
    private baseUrl;
    constructor(config: {
        apiKey: string;
        baseUrl?: string;
    });
    createSession(params: OnRampSessionParams): Promise<RampSession>;
    createPayoutSession(params: OffRampSessionParams): Promise<RampSession>;
    private chainToBlockchain;
    getCapabilities(): ProviderCapabilities;
}
//# sourceMappingURL=banxa.provider.d.ts.map