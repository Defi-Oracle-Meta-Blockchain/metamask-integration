# Chain 138 Snap Pricing Requirements

This note traces what is required to make Chain 138 pricing "MetaMask-Snap-grade" end to end for both:

- current valuation on EOA and token detail surfaces
- transfer-time locked valuation on transaction detail surfaces

It is based on the current live API contract and the current Snap implementation in this repo.

## Current state

The Snap already supports:

- network config via `get_networks` and `get_chain138_config`
- token list via `get_token_list`
- current market summary via `get_market_summary`
- swap and bridge helper RPCs

The token-aggregation API already supports:

- current token summaries via `GET /api/v1/tokens`
- token detail via `GET /api/v1/tokens/:address`
- OHLCV candles via `GET /api/v1/tokens/:address/ohlcv`
- historical point lookup via `GET /api/v1/tokens/:address/price-at`

The gap is that the Snap only consumes current market summary, while transfer-time pricing still depends on OHLCV coverage that is not yet reliably backfilled.

## What the Snap calls today

Current Snap RPC implementation:

- `get_market_summary` calls `GET {apiBaseUrl}/api/v1/tokens?chainId={chainId}&limit=50`
- `get_oracles` calls `GET {apiBaseUrl}/api/v1/config?chainId={chainId}`
- `get_networks` calls `GET {apiBaseUrl}/api/v1/networks`

Relevant implementation:

- `metamask-integration/chain138-snap/packages/snap/src/index.tsx`
- `smom-dbis-138/services/token-aggregation/src/api/routes/tokens.ts`

## Verified live payloads

### 1. Networks

Request:

```http
GET /token-aggregation/api/v1/networks
```

Live shape:

```json
{
  "source": "built-in",
  "version": "1.0.0",
  "networks": [
    {
      "chainId": "0x8a",
      "chainIdDecimal": 138,
      "chainName": "DeFi Oracle Meta Mainnet",
      "rpcUrls": ["..."],
      "blockExplorerUrls": ["https://explorer.d-bis.org"],
      "nativeCurrency": {
        "name": "Ether",
        "symbol": "ETH",
        "decimals": 18
      },
      "iconUrls": ["..."],
      "oracles": [
        {
          "name": "ETH/USD",
          "address": "0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6",
          "decimals": 8
        }
      ]
    }
  ]
}
```

### 2. Oracles config

Request:

```http
GET /token-aggregation/api/v1/config?chainId=138
```

Live shape:

```json
{
  "source": "built-in",
  "version": "1.0.0",
  "chainId": 138,
  "oracles": [
    {
      "name": "ETH/USD",
      "address": "0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6",
      "decimals": 8
    }
  ]
}
```

### 3. Current market summary

Request:

```http
GET /token-aggregation/api/v1/tokens?chainId=138&limit=2
```

Live shape:

```json
{
  "source": "db",
  "pagination": {
    "limit": 2,
    "offset": 0,
    "count": 2
  },
  "tokens": [
    {
      "address": "0x...",
      "symbol": "USDT",
      "name": "Tether USD (Chain 138)",
      "market": {
        "chainId": 138,
        "tokenAddress": "0x...",
        "priceUsd": 1,
        "volume24h": 0,
        "volume7d": 0,
        "volume30d": 0,
        "liquidityUsd": 12104786.72586392,
        "holdersCount": 0,
        "transfers24h": 0,
        "lastUpdated": "2026-04-26T03:31:01.926Z"
      },
      "pricing": {
        "priceUsd": 1,
        "sourceLayer": "indexer_market",
        "precedenceRank": 1,
        "stale": false,
        "maxAgeSeconds": 900,
        "asOf": "2026-04-26T03:31:01.926Z",
        "ageSeconds": 3
      },
      "explorer": {
        "chainId": 138,
        "explorerBaseUrl": "https://explorer.d-bis.org",
        "addressUrl": "https://explorer.d-bis.org/address/0x...",
        "tokenUrl": "https://explorer.d-bis.org/address/0x..."
      }
    }
  ]
}
```

### 4. Historical point lookup

Request:

```http
GET /token-aggregation/api/v1/tokens/0xc02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/price-at?chainId=138&timestamp=2026-04-26T01:33:02.000Z
```

Live shape today:

```json
{
  "chainId": 138,
  "tokenAddress": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
  "requestedTimestamp": "2026-04-26T01:33:02.000Z",
  "effectiveTimestamp": "2026-04-26T03:31:01.988Z",
  "priceUsd": 2490,
  "source": "current_market_fallback"
}
```

This proves the endpoint contract exists, but also proves that the current result is not yet a locked historical candle for this timestamp.

## Why transfer-time pricing is not fully locked yet

### 1. The Snap does not call historical pricing yet

Current Snap market RPCs only call:

- `GET /api/v1/tokens`

They do not call:

- `GET /api/v1/tokens/:address/price-at`
- `GET /api/v1/tokens/:address/ohlcv`

So the Snap is current-price compatible, but not transfer-time-price aware.

### 2. The indexer only rolls OHLCV for the last 7 days

Current indexing flow:

- discovers pools
- indexes tokens
- updates current market data
- generates OHLCV for `5m`, `1h`, `24h`
- only for `now - 7 days` through `now`

That means a historical valuation request can miss if:

- `swap_events` were never backfilled for the requested token or time
- the requested timestamp is older than the rolling backfill window
- the token had sparse or no swap coverage in the indexed pool set

### 3. Historical lookup deliberately falls back

The current `price-at` route tries:

1. `5m` OHLCV near the timestamp
2. broader `15m`, `1h`, `4h`, `24h` windows
3. current market data fallback
4. canonical fallback

This is correct defensive behavior for explorer UX, but it is not sufficient for wallet-grade "locked at transfer time" semantics unless the caller can distinguish a true historical hit from a fallback. The `source` field already exposes that distinction.

## What is required

## A. Backfill OHLCV history

Minimum requirement:

- backfill `swap_events` and `token_ohlcv` for the token universe the Snap will price
- include native-wrapped asset pairs for WETH9/WETH10 and key stables
- preserve enough history to cover transaction lookback expectations

Required data sources:

- on-chain swap event replay into `swap_events`
- optional external pair OHLCV seeding where on-chain coverage is missing, using the existing CMC pair OHLCV adapter

Implementation requirements:

- add an explicit backfill job, not just rolling indexer generation
- support `fromBlock` / `toBlock` or `fromTimestamp` / `toTimestamp`
- generate `5m`, `15m`, `1h`, `4h`, `24h` candles, not only `5m`, `1h`, `24h`
- seed historical candles before enabling wallet-grade transfer-time valuation

Operational acceptance criteria:

- `price-at` for known transaction timestamps returns `source: ohlcv_*`, not `current_market_fallback`
- the requested timestamp and effective timestamp are within the expected candle tolerance
- historical coverage exists across the curated Chain 138 token set

## B. Expose a Snap-ready pricing method

The Snap needs a wallet-facing RPC for pricing, instead of overloading `get_market_summary`.

Recommended new Snap RPC methods:

- `get_current_price`
- `get_historical_price`
- `get_pricing_context`

Recommended behavior:

### `get_current_price`

Request params:

```json
{
  "apiBaseUrl": "https://explorer.d-bis.org/token-aggregation",
  "chainId": 138,
  "address": "0x..."
}
```

Recommended response:

```json
{
  "chainId": 138,
  "address": "0x...",
  "priceUsd": 1,
  "asOf": "2026-04-26T03:31:01.926Z",
  "sourceLayer": "indexer_market",
  "stale": false
}
```

This can be implemented by calling `GET /api/v1/tokens/:address?chainId=138` and projecting `token.pricing` plus selected `token.market` fields.

### `get_historical_price`

Request params:

```json
{
  "apiBaseUrl": "https://explorer.d-bis.org/token-aggregation",
  "chainId": 138,
  "address": "0x...",
  "timestamp": "2026-04-26T01:33:02.000Z"
}
```

Recommended response:

```json
{
  "chainId": 138,
  "address": "0x...",
  "requestedTimestamp": "2026-04-26T01:33:02.000Z",
  "effectiveTimestamp": "2026-04-26T01:30:00.000Z",
  "priceUsd": 2490,
  "source": "ohlcv_5m",
  "historical": true
}
```

Important rule:

- if `source` is `current_market_fallback` or `canonical_fallback`, the response should include `historical: false`
- callers must not treat fallback data as transfer-locked valuation

### `get_pricing_context`

This is the most Snap-friendly single call.

Request params:

```json
{
  "apiBaseUrl": "https://explorer.d-bis.org/token-aggregation",
  "chainId": 138,
  "address": "0x...",
  "timestamp": "2026-04-26T01:33:02.000Z"
}
```

Recommended response:

```json
{
  "chainId": 138,
  "address": "0x...",
  "current": {
    "priceUsd": 2490,
    "asOf": "2026-04-26T03:31:01.988Z",
    "sourceLayer": "indexer_market",
    "stale": false
  },
  "historical": {
    "requestedTimestamp": "2026-04-26T01:33:02.000Z",
    "effectiveTimestamp": "2026-04-26T01:30:00.000Z",
    "priceUsd": 2488.42,
    "source": "ohlcv_5m",
    "locked": true
  }
}
```

This gives the Snap everything it needs for:

- current wallet balance valuation
- transaction review valuation
- explicit distinction between live and transfer-time price

## C. Exact payload shape the Snap/provider should call

If we do not add a new backend endpoint immediately, the Snap/provider should call these existing routes:

### Current valuation

Use:

```http
GET /api/v1/tokens/:address?chainId=138
```

Read:

- `token.market.priceUsd`
- `token.market.lastUpdated`
- `token.pricing.priceUsd`
- `token.pricing.asOf`
- `token.pricing.sourceLayer`
- `token.pricing.stale`

### Historical valuation

Use:

```http
GET /api/v1/tokens/:address/price-at?chainId=138&timestamp={ISO_8601}
```

Read:

- `chainId`
- `tokenAddress`
- `requestedTimestamp`
- `effectiveTimestamp`
- `priceUsd`
- `source`

Caller rule:

- only treat `source` values starting with `ohlcv_` as locked historical valuation
- treat `current_market_fallback` and `canonical_fallback` as non-historical fallback data

### Optional charting

Use:

```http
GET /api/v1/tokens/:address/ohlcv?chainId=138&interval=1h&from={ISO_8601}&to={ISO_8601}
```

Read:

- `chainId`
- `tokenAddress`
- `interval`
- `data[]` with `timestamp`, `open`, `high`, `low`, `close`, `volume`, `volumeUsd`

## Recommended implementation order

1. Add a backfill job for `swap_events` and `token_ohlcv`.
2. Expand candle generation to include `15m` and `4h` in the indexer, not only the API fallback reader.
3. Add a single Snap-oriented API response, preferably `GET /api/v1/tokens/:address/pricing-context`.
4. Add new Snap RPC methods for current and historical pricing.
5. Update the companion site and provider examples to call the new pricing RPCs.
6. Add release checks that fail if curated assets return fallback instead of `ohlcv_*` for known test timestamps.

## Practical definition of "MetaMask-Snap-grade"

The pricing path is Snap-grade only when all of the following are true:

- current price is available from the API for curated assets
- historical price is available for transaction timestamps from OHLCV, not fallback
- the Snap exposes current and historical valuation as distinct methods or a clearly typed combined method
- the caller can programmatically distinguish `locked historical` from `best-effort fallback`
- docs and examples show the exact request and response contract
