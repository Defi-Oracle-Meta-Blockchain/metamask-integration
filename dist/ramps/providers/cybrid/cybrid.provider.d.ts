/**
 * Cybrid fiat↔crypto on/off-ramp provider
 * Full embedded platform API
 * Docs: https://cybrid.xyz
 */
import type { IOnRampProvider, IOffRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';
export declare class CybridProvider implements IOnRampProvider, IOffRampProvider {
    readonly id = "cybrid";
    private apiKey;
    private baseUrl;
    constructor(config: {
        apiKey: string;
        baseUrl?: string;
    });
    createSession(params: OnRampSessionParams): Promise<RampSession>;
    createPayoutSession(params: OffRampSessionParams): Promise<RampSession>;
    getCapabilities(): ProviderCapabilities;
}
//# sourceMappingURL=cybrid.provider.d.ts.map