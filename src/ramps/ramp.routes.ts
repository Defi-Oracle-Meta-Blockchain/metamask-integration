/**
 * Ramp API routes - on-ramp and off-ramp session creation, quotes, providers
 */

import { Router, Request, Response, NextFunction } from 'express';
import type { OnRampSessionParams, OffRampSessionParams, RampQuoteParams } from './types';
import { rampFactoryService } from './ramp-factory.service';
import type { RampProviderId } from './ramp-factory.service';

const router = Router();

function safeJsonParse<T>(body: unknown, fallback: T): T {
  if (body && typeof body === 'object') return body as T;
  return fallback;
}

/**
 * POST /ramps/on-ramp/session
 * Create buy session - returns URL for MoonPay/Ramp/Onramper widget
 */
router.post('/on-ramp/session', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body = safeJsonParse<Partial<OnRampSessionParams> & { provider?: RampProviderId }>(
      req.body,
      {}
    );
    const { walletAddress, amount, fiatCurrency, cryptoCurrency, chainId, email, redirectUrl, provider } = body;

    if (!walletAddress || !amount || !fiatCurrency || !cryptoCurrency) {
      res.status(400).json({
        success: false,
        error: 'Missing required fields: walletAddress, amount, fiatCurrency, cryptoCurrency',
        timestamp: new Date(),
      });
      return;
    }

    const params: OnRampSessionParams = {
      walletAddress,
      amount: String(amount),
      fiatCurrency,
      cryptoCurrency,
      chainId,
      email,
      redirectUrl,
    };

    const session = await rampFactoryService.createOnRampSession(params, provider);
    res.status(201).json({ success: true, data: session, timestamp: new Date() });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /ramps/off-ramp/session
 * Create sell/payout session
 */
router.post('/off-ramp/session', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body = safeJsonParse<Partial<OffRampSessionParams> & { provider?: RampProviderId }>(
      req.body,
      {}
    );
    const {
      walletAddress,
      amount,
      fiatCurrency,
      cryptoCurrency,
      chainId,
      destinationAccount,
      redirectUrl,
      provider,
    } = body;

    if (!walletAddress || !amount || !fiatCurrency || !cryptoCurrency) {
      res.status(400).json({
        success: false,
        error: 'Missing required fields: walletAddress, amount, fiatCurrency, cryptoCurrency',
        timestamp: new Date(),
      });
      return;
    }

    const params: OffRampSessionParams = {
      walletAddress,
      amount: String(amount),
      fiatCurrency,
      cryptoCurrency,
      chainId,
      destinationAccount,
      redirectUrl,
    };

    const session = await rampFactoryService.createOffRampSession(params, provider);
    res.status(201).json({ success: true, data: session, timestamp: new Date() });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /ramps/quote
 * Get quote for buy/sell
 * Query: amount, fiatCurrency, cryptoCurrency, side (buy|sell), chainId?, provider?
 */
router.get('/quote', async (req: Request, res: Response, next: NextFunction) => {
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

    const params: RampQuoteParams = {
      amount: String(amount),
      fiatCurrency: String(fiatCurrency),
      cryptoCurrency: String(cryptoCurrency),
      side,
      chainId: chainId ? Number(chainId) : undefined,
    };

    const quote = await rampFactoryService.getQuote(
      params,
      provider ? (provider as RampProviderId) : undefined
    );

    if (!quote) {
      res.status(404).json({
        success: false,
        error: 'No quote available for the requested pair',
        timestamp: new Date(),
      });
      return;
    }

    res.json({ success: true, data: quote, timestamp: new Date() });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /ramps/providers
 * List enabled providers and capabilities
 */
router.get('/providers', (_req: Request, res: Response, next: NextFunction) => {
  try {
    const providers = rampFactoryService.getProviders();
    res.json({ success: true, data: providers, timestamp: new Date() });
  } catch (err) {
    next(err);
  }
});

export default router;
