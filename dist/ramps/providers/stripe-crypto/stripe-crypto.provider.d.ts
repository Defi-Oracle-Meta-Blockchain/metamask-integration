/**
 * Stripe Crypto Onramp provider (on-ramp only)
 * Creates on-ramp sessions via Stripe API
 */
import type { IOnRampProvider } from '../../provider.interface';
import type { OnRampSessionParams, RampSession, ProviderCapabilities } from '../../types';
export declare class StripeCryptoProvider implements IOnRampProvider {
    readonly id = "stripe-crypto";
    private apiKey;
    constructor(config: {
        apiKey: string;
    });
    createSession(params: OnRampSessionParams): Promise<RampSession>;
    private chainToNetwork;
    getCapabilities(): ProviderCapabilities;
}
//# sourceMappingURL=stripe-crypto.provider.d.ts.map