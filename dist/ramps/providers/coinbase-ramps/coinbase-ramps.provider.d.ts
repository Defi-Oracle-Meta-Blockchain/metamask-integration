/**
 * Coinbase Onramp and Offramp provider
 * Creates hosted widget URL sessions via Coinbase CDP
 */
import type { IOnRampProvider, IOffRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, OffRampSessionParams, RampSession, ProviderCapabilities } from '../../types';
export declare class CoinbaseRampsProvider implements IOnRampProvider, IOffRampProvider {
    readonly id = "coinbase-ramps";
    private appId;
    constructor(config: {
        appId: string;
    });
    createSession(params: OnRampSessionParams): Promise<RampSession>;
    createPayoutSession(params: OffRampSessionParams): Promise<RampSession>;
    getCapabilities(): ProviderCapabilities;
}
//# sourceMappingURL=coinbase-ramps.provider.d.ts.map