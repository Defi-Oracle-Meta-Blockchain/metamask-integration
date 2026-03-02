/**
 * HoneyCoin Offramps provider (off-ramp focused)
 * Stablecoins to bank/mobile money - docs.honeycoin.app
 */
import type { IOffRampProvider } from '../../provider.interface';
import type { OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';
export declare class HoneyCoinProvider implements IOffRampProvider {
    readonly id = "honeycoin";
    private apiKey;
    private baseUrl;
    constructor(config: {
        apiKey: string;
        baseUrl?: string;
    });
    createPayoutSession(params: OffRampSessionParams): Promise<RampSession>;
    getCapabilities(): ProviderCapabilities;
}
//# sourceMappingURL=honeycoin.provider.d.ts.map