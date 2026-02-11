import type { OnRpcRequestHandler } from '@metamask/snaps-sdk';
import { Box, Text, Bold } from '@metamask/snaps-sdk/jsx';

/** Token-aggregation or market API base URL; dapp passes apiBaseUrl for dynamic config */
const DEFAULT_MARKET_API_BASE = '';

/** RPC params: apiBaseUrl and optional override URLs for networks, token list, bridge list */
export type SnapRpcParams = {
  apiBaseUrl?: string;
  /** When set, get_networks / get_chain138_config fetch this URL instead of apiBaseUrl */
  networksUrl?: string;
  /** When set, get_token_list / get_token_list_url use this URL instead of apiBaseUrl */
  tokenListUrl?: string;
  /** When set, get_bridge_routes / show_bridge_routes fetch this URL instead of apiBaseUrl */
  bridgeListUrl?: string;
  chainId?: number;
  [key: string]: unknown;
};

/**
 * Get API base URL from request params, trimmed of trailing slash.
 *
 * @param params - Request params with optional apiBaseUrl.
 * @returns API base URL string.
 */
function getApiBase(params: { apiBaseUrl?: string } | undefined): string {
  return (params?.apiBaseUrl ?? DEFAULT_MARKET_API_BASE).replace(/\/$/u, '');
}

/**
 * Fetch networks from token-aggregation API.
 *
 * @param apiBase - API base URL.
 * @returns Networks response with version and networks array.
 */
async function fetchNetworks(apiBase: string) {
  const res = await fetch(`${apiBase}/api/v1/networks`);
  if (!res.ok) {
    throw new Error(`HTTP ${res.status}`);
  }
  return res.json() as Promise<{
    version?: string;
    networks?: {
      chainId: string;
      chainIdDecimal: number;
      chainName: string;
      rpcUrls: string[];
      nativeCurrency: { name: string; symbol: string; decimals: number };
      blockExplorerUrls: string[];
      iconUrls?: string[];
      oracles?: { name: string; address: string }[];
    }[];
  }>;
}

/**
 * Handle incoming JSON-RPC requests, sent through `wallet_invokeSnap`.
 *
 * @param options - RPC request options.
 * @param options.origin - Origin of the request.
 * @param options.request - JSON-RPC request object.
 * @returns Response for the RPC method.
 */
export const onRpcRequest: OnRpcRequestHandler = async ({
  origin,
  request,
}) => {
  const params = (request.params as SnapRpcParams | undefined) ?? {};
  const base = getApiBase(params);
  const networksUrl = params.networksUrl?.trim();
  const tokenListUrl = params.tokenListUrl?.trim();
  const bridgeListUrl = params.bridgeListUrl?.trim();

  switch (request.method) {
    case 'get_networks': {
      if (networksUrl) {
        try {
          const res = await fetch(networksUrl);
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          const data = (await res.json()) as { version?: string; networks?: unknown[] };
          return { version: data.version, networks: data.networks ?? [] };
        } catch (error) {
          return {
            error: error instanceof Error ? error.message : 'Failed to fetch networks URL',
            version: undefined,
            networks: [],
          };
        }
      }
      if (!base) {
        return {
          error:
            'Pass apiBaseUrl or networksUrl to fetch networks',
          version: undefined,
          networks: [],
        };
      }
      try {
        const data = await fetchNetworks(base);
        return { version: data.version, networks: data.networks ?? [] };
      } catch (error) {
        return {
          error:
            error instanceof Error ? error.message : 'Failed to fetch networks',
          version: undefined,
          networks: [],
        };
      }
    }

    case 'get_chain138_config': {
      const loadNetworks = async () => {
        if (networksUrl) {
          const res = await fetch(networksUrl);
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          const data = (await res.json()) as { networks?: { chainIdDecimal?: number }[] };
          return data.networks ?? [];
        }
        if (base) {
          const data = await fetchNetworks(base);
          return data.networks ?? [];
        }
        return null;
      };
      try {
        const networks = await loadNetworks();
        if (networks === null) {
          return { error: 'Pass apiBaseUrl or networksUrl to fetch chain config' };
        }
        const chain138 = networks.find((net: { chainIdDecimal?: number }) => net.chainIdDecimal === 138);
        if (!chain138) {
          return { error: 'Chain 138 not found in networks response' };
        }
        return {
          chainId: (chain138 as { chainId?: string }).chainId,
          chainIdDecimal: chain138.chainIdDecimal,
          chainName: (chain138 as { chainName?: string }).chainName,
          rpcUrls: (chain138 as { rpcUrls?: string[] }).rpcUrls,
          nativeCurrency: (chain138 as { nativeCurrency?: unknown }).nativeCurrency,
          blockExplorerUrls: (chain138 as { blockExplorerUrls?: string[] }).blockExplorerUrls,
          oracles: (chain138 as { oracles?: unknown }).oracles,
        };
      } catch (error) {
        return {
          error:
            error instanceof Error
              ? error.message
              : 'Failed to fetch chain config',
        };
      }
    }

    case 'get_chain138_market_chains': {
      if (!base) {
        return {
          error:
            'Pass apiBaseUrl (token-aggregation service URL) to fetch market chains',
          chains: [],
        };
      }
      try {
        const res = await fetch(`${base}/api/v1/chains`);
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }
        const data = await res.json();
        return data;
      } catch (error) {
        return {
          error:
            error instanceof Error ? error.message : 'Failed to fetch chains',
          chains: [],
        };
      }
    }

    case 'get_token_list_url': {
      if (tokenListUrl) {
        return {
          tokenListUrl,
          description:
            'Add this URL in MetaMask Settings -> Token list to get dynamic token list for Chain 138 and ALL Mainnet.',
        };
      }
      if (!base) {
        return {
          error: 'Pass apiBaseUrl or tokenListUrl to get token list URL',
          tokenListUrl: undefined,
        };
      }
      return {
        tokenListUrl: `${base}/api/v1/report/token-list`,
        description:
          'Add this URL in MetaMask Settings -> Token list to get dynamic token list for Chain 138 and ALL Mainnet.',
      };
    }

    case 'get_token_list': {
      if (tokenListUrl) {
        const chainIdParam = params?.chainId as number | undefined;
        const url = chainIdParam
          ? `${tokenListUrl}${tokenListUrl.includes('?') ? '&' : '?'}chainId=${chainIdParam}`
          : tokenListUrl;
        try {
          const res = await fetch(url);
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          const data = await res.json();
          return data;
        } catch (error) {
          return {
            error: error instanceof Error ? error.message : 'Failed to fetch token list URL',
            tokens: [],
          };
        }
      }
      if (!base) {
        return {
          error: 'Pass apiBaseUrl or tokenListUrl to fetch token list',
          tokens: [],
        };
      }
      const chainIdParam = params?.chainId as number | undefined;
      const url = chainIdParam
        ? `${base}/api/v1/report/token-list?chainId=${chainIdParam}`
        : `${base}/api/v1/report/token-list`;
      try {
        const res = await fetch(url);
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }
        const data = await res.json();
        return data;
      } catch (error) {
        return {
          error:
            error instanceof Error
              ? error.message
              : 'Failed to fetch token list',
          tokens: [],
        };
      }
    }

    case 'get_oracles': {
      if (!base) {
        return { error: 'Pass apiBaseUrl to fetch oracles config', chains: [] };
      }
      const chainIdParam = params?.chainId as number | undefined;
      const configUrl = chainIdParam
        ? `${base}/api/v1/config?chainId=${chainIdParam}`
        : `${base}/api/v1/config`;
      try {
        const res = await fetch(configUrl);
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }
        return await res.json();
      } catch (error) {
        return {
          error:
            error instanceof Error ? error.message : 'Failed to fetch oracles',
          chains: [],
        };
      }
    }

    case 'show_dynamic_info': {
      const hasAny = base || networksUrl || tokenListUrl;
      if (!hasAny) {
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  Pass apiBaseUrl, networksUrl, or tokenListUrl to see dynamic networks and token list URL.
                </Text>
              </Box>
            ),
          },
        });
      }
      try {
        let chainNames = 'N/A';
        if (networksUrl) {
          const res = await fetch(networksUrl);
          if (res.ok) {
            const data = (await res.json()) as { networks?: { chainName?: string; chainIdDecimal?: number }[] };
            const nets = data.networks ?? [];
            chainNames = nets.map((n) => `${n.chainName ?? ''} (${n.chainIdDecimal ?? ''})`).join(', ') || 'None';
          }
        } else if (base) {
          const data = await fetchNetworks(base);
          const networks = data.networks ?? [];
          chainNames = networks.map((net) => `${net.chainName} (${net.chainIdDecimal})`).join(', ') || 'None';
        }
        const displayTokenListUrl = tokenListUrl || (base ? `${base}/api/v1/report/token-list` : '');
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'confirmation',
            content: (
              <Box>
                <Text>
                  <Bold>Dynamic networks</Bold>
                </Text>
                <Text>{chainNames}</Text>
                <Text>
                  <Bold>Token list URL</Bold>
                </Text>
                <Text>{displayTokenListUrl || 'N/A'}</Text>
                <Text>
                  Add the URL in MetaMask Settings - Token list for
                  auto-updating tokens.
                </Text>
              </Box>
            ),
          },
        });
      } catch (error) {
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  Failed to fetch:{' '}
                  {error instanceof Error ? error.message : 'Unknown error'}
                </Text>
              </Box>
            ),
          },
        });
      }
    }

    case 'get_market_summary': {
      if (!base) {
        return {
          error:
            'Pass apiBaseUrl (token-aggregation service URL) to fetch market summary',
          tokens: [],
        };
      }
      const chainIdParam = (params?.chainId as number | undefined) ?? 138;
      try {
        const res = await fetch(
          `${base}/api/v1/tokens?chainId=${chainIdParam}&limit=50`,
        );
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }
        const data = (await res.json()) as {
          tokens?: Array<{
            symbol?: string;
            name?: string;
            address?: string;
            market?: { priceUsd?: number; volume24h?: number };
          }>;
        };
        const tokens = (data.tokens ?? []).map((t) => ({
          symbol: t.symbol,
          name: t.name,
          address: t.address,
          market: t.market
            ? { priceUsd: t.market.priceUsd, volume24h: t.market.volume24h }
            : undefined,
        }));
        return { tokens };
      } catch (error) {
        return {
          error:
            error instanceof Error
              ? error.message
              : 'Failed to fetch market summary',
          tokens: [],
        };
      }
    }

    case 'get_swap_quote': {
      if (!base) {
        return {
          error:
            'Pass apiBaseUrl (token-aggregation service URL) to fetch swap quote',
          amountOut: undefined,
        };
      }
      const chainIdParam = (params?.chainId as number | undefined) ?? 138;
      const tokenIn = params?.tokenIn as string | undefined;
      const tokenOut = params?.tokenOut as string | undefined;
      const amountIn = params?.amountIn as string | undefined;
      if (!tokenIn || !tokenOut || amountIn === undefined) {
        return {
          error: 'Missing params: tokenIn, tokenOut, amountIn',
          amountOut: undefined,
        };
      }
      try {
        const url = new URL(`${base}/api/v1/quote`);
        url.searchParams.set('chainId', String(chainIdParam));
        url.searchParams.set('tokenIn', tokenIn);
        url.searchParams.set('tokenOut', tokenOut);
        url.searchParams.set('amountIn', String(amountIn));
        const res = await fetch(url.toString());
        const data = (await res.json()) as {
          amountOut?: string | null;
          error?: string;
          poolAddress?: string | null;
        };
        if (!res.ok) {
          return {
            error: data.error ?? `HTTP ${res.status}`,
            amountOut: undefined,
          };
        }
        return {
          amountOut: data.amountOut ?? undefined,
          error: data.error,
          poolAddress: data.poolAddress,
        };
      } catch (error) {
        return {
          error:
            error instanceof Error
              ? error.message
              : 'Failed to fetch swap quote',
          amountOut: undefined,
        };
      }
    }

    case 'show_swap_quote': {
      if (!base) {
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  Pass apiBaseUrl to see swap quote (tokenIn, tokenOut,
                  amountIn).
                </Text>
              </Box>
            ),
          },
        });
      }
      const chainIdParam = (params?.chainId as number | undefined) ?? 138;
      const tokenIn = params?.tokenIn as string | undefined;
      const tokenOut = params?.tokenOut as string | undefined;
      const amountIn = params?.amountIn as string | undefined;
      if (!tokenIn || !tokenOut || amountIn === undefined) {
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  Missing params: tokenIn, tokenOut, amountIn. Pass them to
                  show_swap_quote.
                </Text>
              </Box>
            ),
          },
        });
      }
      try {
        const url = new URL(`${base}/api/v1/quote`);
        url.searchParams.set('chainId', String(chainIdParam));
        url.searchParams.set('tokenIn', tokenIn);
        url.searchParams.set('tokenOut', tokenOut);
        url.searchParams.set('amountIn', String(amountIn));
        const res = await fetch(url.toString());
        const data = (await res.json()) as {
          amountOut?: string | null;
          error?: string;
        };
        if (!res.ok || data.error) {
          return snap.request({
            method: 'snap_dialog',
            params: {
              type: 'alert',
              content: (
                <Box>
                  <Text>
                    <Bold>Swap quote</Bold>
                  </Text>
                  <Text>{data.error ?? `HTTP ${res.status}`}</Text>
                </Box>
              ),
            },
          });
        }
        const out = data.amountOut ?? '0';
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  <Bold>Swap quote</Bold>
                </Text>
                <Text>
                  In: {amountIn} (raw) → Out: ~{out} (raw)
                </Text>
                <Text>Use explorer or dApp to execute swap.</Text>
              </Box>
            ),
          },
        });
      } catch (error) {
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  Failed to fetch quote:{' '}
                  {error instanceof Error ? error.message : 'Unknown error'}
                </Text>
              </Box>
            ),
          },
        });
      }
    }

    case 'get_bridge_routes': {
      const bridgeUrl = bridgeListUrl || (base ? `${base}/api/v1/bridge/routes` : '');
      if (!bridgeUrl) {
        return {
          error: 'Pass apiBaseUrl or bridgeListUrl to fetch bridge routes',
          routes: undefined,
          chain138Bridges: undefined,
        };
      }
      try {
        const res = await fetch(bridgeUrl);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = (await res.json()) as {
          routes?: Record<string, Record<string, string>>;
          chain138Bridges?: Record<string, string>;
        };
        return {
          routes: data.routes,
          chain138Bridges: data.chain138Bridges,
        };
      } catch (error) {
        return {
          error:
            error instanceof Error
              ? error.message
              : 'Failed to fetch bridge routes',
          routes: undefined,
          chain138Bridges: undefined,
        };
      }
    }

    case 'show_bridge_routes': {
      const showBridgeUrl = bridgeListUrl || (base ? `${base}/api/v1/bridge/routes` : '');
      if (!showBridgeUrl) {
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  Pass apiBaseUrl or bridgeListUrl to see bridge routes (CCIP WETH9 / WETH10).
                </Text>
              </Box>
            ),
          },
        });
      }
      try {
        const res = await fetch(showBridgeUrl);
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }
        const data = (await res.json()) as {
          routes?: Record<string, Record<string, string>>;
          chain138Bridges?: Record<string, string>;
        };
        const lines: string[] = [];
        if (data.chain138Bridges) {
          lines.push(
            `WETH9 Bridge (138): ${String(data.chain138Bridges.weth9 ?? '').slice(0, 10)}...`,
          );
          lines.push(
            `WETH10 Bridge (138): ${String(data.chain138Bridges.weth10 ?? '').slice(0, 10)}...`,
          );
        }
        if (data.routes?.weth9?.['Ethereum Mainnet (1)']) {
          lines.push('WETH9 → Ethereum Mainnet');
        }
        if (data.routes?.weth10?.['Ethereum Mainnet (1)']) {
          lines.push('WETH10 → Ethereum Mainnet');
        }
        lines.push('');
        lines.push('Use the explorer to execute bridge transfers.');
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  <Bold>CCIP Bridge Routes</Bold>
                </Text>
                <Text>{lines.join('\n')}</Text>
              </Box>
            ),
          },
        });
      } catch (error) {
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  Failed to fetch bridge routes:{' '}
                  {error instanceof Error ? error.message : 'Unknown error'}
                </Text>
              </Box>
            ),
          },
        });
      }
    }

    case 'show_market_data': {
      if (!base) {
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  Pass apiBaseUrl to see market data (prices and tokens).
                </Text>
              </Box>
            ),
          },
        });
      }
      const chainIdParam = (params?.chainId as number | undefined) ?? 138;
      try {
        const res = await fetch(
          `${base}/api/v1/tokens?chainId=${chainIdParam}&limit=20`,
        );
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}`);
        }
        const data = (await res.json()) as {
          tokens?: Array<{
            symbol?: string;
            name?: string;
            market?: { priceUsd?: number };
          }>;
        };
        const tokens = data.tokens ?? [];
        const lines =
          tokens.length === 0
            ? 'No tokens with market data.'
            : tokens
                .map((t) => {
                  const price =
                    t.market?.priceUsd != null
                      ? `$${Number(t.market.priceUsd).toFixed(4)}`
                      : '—';
                  return `${t.symbol ?? t.name ?? 'Token'}: ${price}`;
                })
                .join('\n');
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  <Bold>Market data (Chain {String(chainIdParam)})</Bold>
                </Text>
                <Text>{lines}</Text>
              </Box>
            ),
          },
        });
      } catch (error) {
        return snap.request({
          method: 'snap_dialog',
          params: {
            type: 'alert',
            content: (
              <Box>
                <Text>
                  Failed to fetch market data:{' '}
                  {error instanceof Error ? error.message : 'Unknown error'}
                </Text>
              </Box>
            ),
          },
        });
      }
    }

    case 'hello':
      return snap.request({
        method: 'snap_dialog',
        params: {
          type: 'confirmation',
          content: (
            <Box>
              <Text>
                Hello, <Bold>{origin}</Bold>!
              </Text>
              <Text>Chain 138 (DeFi Oracle Meta Mainnet) Snap.</Text>
              <Text>
                Use get_networks or get_chain138_config for
                wallet_addEthereumChain.
              </Text>
            </Box>
          ),
        },
      });

    default:
      throw new Error('Method not found.');
  }
};
