/**
 * Standalone ramp API server
 * Mount ramp routes at /ramps
 */

import express from 'express';
import rampRoutes from './ramp.routes';

const app = express();
const PORT = process.env.RAMP_API_PORT || 3080;

app.use(express.json());
app.use('/ramps', rampRoutes);

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'ramp-api', timestamp: new Date() });
});

app.listen(PORT, () => {
  console.log(`Ramp API server listening on port ${PORT}`);
  console.log(`  POST /ramps/on-ramp/session`);
  console.log(`  POST /ramps/off-ramp/session`);
  console.log(`  GET  /ramps/quote`);
  console.log(`  GET  /ramps/providers`);
});
