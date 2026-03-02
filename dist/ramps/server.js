"use strict";
/**
 * Standalone ramp API server
 * Mount ramp routes at /ramps
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const ramp_routes_1 = __importDefault(require("./ramp.routes"));
const app = (0, express_1.default)();
const PORT = process.env.RAMP_API_PORT || 3080;
app.use(express_1.default.json());
app.use('/ramps', ramp_routes_1.default);
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
//# sourceMappingURL=server.js.map