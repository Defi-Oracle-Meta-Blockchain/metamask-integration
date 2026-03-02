"use strict";
/**
 * Ramps module - fiat on/off-ramp integrations
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.HoneyCoinProvider = exports.SardineProvider = exports.CybridProvider = exports.StripeCryptoProvider = exports.CoinbaseRampsProvider = exports.BanxaProvider = exports.TransakProvider = exports.OnramperProvider = exports.RampNetworkProvider = exports.MoonPayProvider = exports.rampRoutes = void 0;
__exportStar(require("./types"), exports);
__exportStar(require("./provider.interface"), exports);
__exportStar(require("./ramp-factory.service"), exports);
var ramp_routes_1 = require("./ramp.routes");
Object.defineProperty(exports, "rampRoutes", { enumerable: true, get: function () { return __importDefault(ramp_routes_1).default; } });
var moonpay_1 = require("./providers/moonpay");
Object.defineProperty(exports, "MoonPayProvider", { enumerable: true, get: function () { return moonpay_1.MoonPayProvider; } });
var ramp_network_1 = require("./providers/ramp-network");
Object.defineProperty(exports, "RampNetworkProvider", { enumerable: true, get: function () { return ramp_network_1.RampNetworkProvider; } });
var onramper_1 = require("./providers/onramper");
Object.defineProperty(exports, "OnramperProvider", { enumerable: true, get: function () { return onramper_1.OnramperProvider; } });
var transak_1 = require("./providers/transak");
Object.defineProperty(exports, "TransakProvider", { enumerable: true, get: function () { return transak_1.TransakProvider; } });
var banxa_1 = require("./providers/banxa");
Object.defineProperty(exports, "BanxaProvider", { enumerable: true, get: function () { return banxa_1.BanxaProvider; } });
var coinbase_ramps_1 = require("./providers/coinbase-ramps");
Object.defineProperty(exports, "CoinbaseRampsProvider", { enumerable: true, get: function () { return coinbase_ramps_1.CoinbaseRampsProvider; } });
var stripe_crypto_1 = require("./providers/stripe-crypto");
Object.defineProperty(exports, "StripeCryptoProvider", { enumerable: true, get: function () { return stripe_crypto_1.StripeCryptoProvider; } });
var cybrid_1 = require("./providers/cybrid");
Object.defineProperty(exports, "CybridProvider", { enumerable: true, get: function () { return cybrid_1.CybridProvider; } });
var sardine_1 = require("./providers/sardine");
Object.defineProperty(exports, "SardineProvider", { enumerable: true, get: function () { return sardine_1.SardineProvider; } });
var honeycoin_1 = require("./providers/honeycoin");
Object.defineProperty(exports, "HoneyCoinProvider", { enumerable: true, get: function () { return honeycoin_1.HoneyCoinProvider; } });
//# sourceMappingURL=index.js.map