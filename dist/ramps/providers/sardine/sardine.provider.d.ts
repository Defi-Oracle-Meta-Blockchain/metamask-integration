/**
 * Sardine Payments Onramp provider (on-ramp focused)
 */
import type { IOnRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, RampSession, ProviderCapabilities } from '../../types';
export declare class SardineProvider implements IOnRampProvider {
    readonly id = "sardine";
    private apiKey;
    private baseUrl;
    constructor(config: {
        apiKey: string;
        baseUrl?: string;
    });
    createSession(params: OnRampSessionParams): Promise<RampSession>;
    getCapabilities(): ProviderCapabilities;
}
//# sourceMappingURL=sardine.provider.d.ts.map