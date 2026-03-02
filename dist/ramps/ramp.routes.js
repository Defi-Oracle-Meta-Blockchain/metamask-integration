"use strict";
/**
 * Ramp API routes - on-ramp and off-ramp session creation, quotes, providers
 */
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const ramp_factory_service_1 = require("./ramp-factory.service");
const router = (0, express_1.Router)();
function safeJsonParse(body, fallback) {
    if (body && typeof body === 'object')
        return body;
    return fallback;
}
/**
 * POST /ramps/on-ramp/session
 * Create buy session - returns URL for MoonPay/Ramp/Onramper widget
 */
router.post('/on-ramp/session', async (req, res, next) => {
    try {
        const body = safeJsonParse(req.body, {});
        const { walletAddress, amount, fiatCurrency, cryptoCurrency, chainId, email, redirectUrl, provider } = body;
        if (!walletAddress || !amount || !fiatCurrency || !cryptoCurrency) {
            res.status(400).json({
                success: false,
                error: 'Missing required fields: walletAddress, amount, fiatCurrency, cryptoCurrency',
                timestamp: new Date(),
            });
            return;
        }
        const params = {
            walletAddress,
            amount: String(amount),
            fiatCurrency,
            cryptoCurrency,
            chainId,
            email,
            redirectUrl,
        };
        const session = await ramp_factory_service_1.rampFactoryService.createOnRampSession(params, provider);
        res.status(201).json({ success: true, data: session, timestamp: new Date() });
    }
    catch (err) {
        next(err);
    }
});
/**
 * POST /ramps/off-ramp/session
 * Create sell/payout session
 */
router.post('/off-ramp/session', async (req, res, next) => {
    try {
        const body = safeJsonParse(req.body, {});
        const { walletAddress, amount, fiatCurrency, cryptoCurrency, chainId, destinationAccount, redirectUrl, provider, } = body;
        if (!walletAddress || !amount || !fiatCurrency || !cryptoCurrency) {
            res.status(400).json({
                success: false,
                error: 'Missing required fields: walletAddress, amount, fiatCurrency, cryptoCurrency',
                timestamp: new Date(),
            });
            return;
        }
        const params = {
            walletAddress,
            amount: String(amount),
            fiatCurrency,
            cryptoCurrency,
            chainId,
            destinationAccount,
            redirectUrl,
        };
        const session = await ramp_factory_service_1.rampFactoryService.createOffRampSession(params, provider);
        res.status(201).json({ success: true, data: session, timestamp: new Date() });
    }
    catch (err) {
        next(err);
    }
});
/**
 * GET /ramps/quote
 * Get quote for buy/sell
 * Query: amount, fiatCurrency, cryptoCurrency, side (buy|sell), chainId?, provider?
 */
router.get('/quote', async (req, res, next) => {
    try {
        const { amount, fiatCurrency, cryptoCurrency, side, chainId, provider } = req.query;
        if (!amount || !fiatCurrency || !cryptoCurrency || !side) {
            res.status(400).json({
                success: false,
                error: 'Missing required query params: amount, fiatCurrency, cryptoCurrency, side',
                timestamp: new Date(),
            });
            return;
        }
        if (side !== 'buy' && side !== 'sell') {
            res.status(400).json({
                success: false,
                error: 'side must be "buy" or "sell"',
                timestamp: new Date(),
            });
            return;
        }
        const params = {
            amount: String(amount),
            fiatCurrency: String(fiatCurrency),
            cryptoCurrency: String(cryptoCurrency),
            side,
            chainId: chainId ? Number(chainId) : undefined,
        };
        const quote = await ramp_factory_service_1.rampFactoryService.getQuote(params, provider ? provider : undefined);
        if (!quote) {
            res.status(404).json({
                success: false,
                error: 'No quote available for the requested pair',
                timestamp: new Date(),
            });
            return;
        }
        res.json({ success: true, data: quote, timestamp: new Date() });
    }
    catch (err) {
        next(err);
    }
});
/**
 * GET /ramps/providers
 * List enabled providers and capabilities
 */
router.get('/providers', (_req, res, next) => {
    try {
        const providers = ramp_factory_service_1.rampFactoryService.getProviders();
        res.json({ success: true, data: providers, timestamp: new Date() });
    }
    catch (err) {
        next(err);
    }
});
exports.default = router;
//# sourceMappingURL=ramp.routes.js.map