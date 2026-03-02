import { useState } from 'react';
import styled from 'styled-components';

import {
  Button,
  ConnectButton,
  InstallFlaskButton,
  ReconnectButton,
  SendHelloButton,
  Card,
} from '../components';
import { defaultSnapOrigin, getSnapApiBaseUrl, getSnapSiteUrl } from '../config';
import {
  useMetaMask,
  useInvokeSnap,
  useMetaMaskContext,
  useRequestSnap,
} from '../hooks';
import { isLocalSnap, shouldDisplayReconnectButton } from '../utils';

const Container = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
  margin-top: 7.6rem;
  margin-bottom: 7.6rem;
  ${({ theme }) => theme.mediaQueries.small} {
    padding-left: 2.4rem;
    padding-right: 2.4rem;
    margin-top: 2rem;
    margin-bottom: 2rem;
    width: auto;
  }
`;

const Heading = styled.h1`
  margin-top: 0;
  margin-bottom: 2.4rem;
  text-align: center;
`;

const Span = styled.span`
  color: ${(props) => props.theme.colors.primary?.default};
`;

const Subtitle = styled.p`
  font-size: ${({ theme }) => theme.fontSizes.large};
  font-weight: 500;
  margin-top: 0;
  margin-bottom: 0;
  ${({ theme }) => theme.mediaQueries.small} {
    font-size: ${({ theme }) => theme.fontSizes.text};
  }
`;

const CardContainer = styled.div`
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: space-between;
  max-width: 64.8rem;
  width: 100%;
  height: 100%;
  margin-top: 1.5rem;
`;

const Notice = styled.div`
  background-color: ${({ theme }) => theme.colors.background?.alternative};
  border: 1px solid ${({ theme }) => theme.colors.border?.default};
  color: ${({ theme }) => theme.colors.text?.alternative};
  border-radius: ${({ theme }) => theme.radii.default};
  padding: 2.4rem;
  margin-top: 2.4rem;
  max-width: 60rem;
  width: 100%;

  & > * {
    margin: 0;
  }
  ${({ theme }) => theme.mediaQueries.small} {
    margin-top: 1.2rem;
    padding: 1.6rem;
  }
`;

const ErrorMessage = styled.div`
  background-color: ${({ theme }) => theme.colors.error?.muted};
  border: 1px solid ${({ theme }) => theme.colors.error?.default};
  color: ${({ theme }) => theme.colors.error?.alternative};
  border-radius: ${({ theme }) => theme.radii.default};
  padding: 2.4rem;
  margin-bottom: 2.4rem;
  margin-top: 2.4rem;
  max-width: 60rem;
  width: 100%;
  ${({ theme }) => theme.mediaQueries.small} {
    padding: 1.6rem;
    margin-bottom: 1.2rem;
    margin-top: 1.2rem;
    max-width: 100%;
  }
`;

const MarketSummaryList = styled.div`
  font-size: ${({ theme }) => theme.fontSizes.small};
  max-height: 12rem;
  overflow-y: auto;
  margin-top: 0.8rem;
`;

/**
 *
 */
const Index = () => {
  const { error } = useMetaMaskContext();
  const { isFlask, snapsDetected, installedSnap } = useMetaMask();
  const requestSnap = useRequestSnap();
  const invokeSnap = useInvokeSnap();
  const apiBaseUrl = getSnapApiBaseUrl();
  const [marketSummary, setMarketSummary] = useState<{
    /**
     *
     */
    tokens: {
      /**
       *
       */
      symbol?: string;
      /**
       *
       */
      name?: string;
      /**
       *
       */
      address?: string;
      /**
       *
       */
      market?: {
        /**
         *
         */
        priceUsd?: number; /**
                            *
                            */
        volume24h?: number;
      };
    }[];
    /**
     *
     */
    error?: string;
  } | null>(null);
  const [swapQuote, setSwapQuote] = useState<{
    /**
     *
     */
    amountOut?: string;
    /**
     *
     */
    error?: string;
    /**
     *
     */
    poolAddress?: string | null;
  } | null>(null);
  const [swapTokenIn, setSwapTokenIn] = useState('');
  const [swapTokenOut, setSwapTokenOut] = useState('');
  const [swapAmountIn, setSwapAmountIn] = useState('');

  const isMetaMaskReady = isLocalSnap(defaultSnapOrigin)
    ? isFlask
    : snapsDetected;

  const snapParams = apiBaseUrl ? { apiBaseUrl } : undefined;

  /**
   *
   */
  const handleSendHelloClick = async () => {
    await invokeSnap(
      snapParams
        ? { method: 'hello', params: snapParams }
        : { method: 'hello' },
    );
  };

  /**
   *
   */
  const handleShowMarketData = async () => {
    if (!apiBaseUrl) {
      return;
    }
    await invokeSnap({
      method: 'show_market_data',
      params: { apiBaseUrl },
    });
  };

  /**
   *
   */
  const handleGetMarketSummary = async () => {
    if (!apiBaseUrl) {
      setMarketSummary({ tokens: [], error: 'Set GATSBY_SNAP_API_BASE_URL' });
      return;
    }
    try {
      const result = (await invokeSnap({
        method: 'get_market_summary',
        params: { apiBaseUrl },
      })) as {
        /**
         *
         */
        tokens?: {
          /**
           *
           */
          symbol?: string;
          /**
           *
           */
          name?: string;
          /**
           *
           */
          address?: string;
          /**
           *
           */
          market?: {
            /**
             *
             */
            priceUsd?: number; /**
                                *
                                */
            volume24h?: number;
          };
        }[];
        /**
         *
         */
        error?: string;
      };
      if (result?.error) {
        setMarketSummary({ tokens: [], error: result.error });
      } else {
        setMarketSummary({ tokens: result?.tokens ?? [] });
      }
    } catch (e) {
      setMarketSummary({
        tokens: [],
        error: e instanceof Error ? e.message : 'Failed to fetch',
      });
    }
  };

  /**
   *
   */
  const handleShowBridgeRoutes = async () => {
    if (!apiBaseUrl) {
      return;
    }
    await invokeSnap({
      method: 'show_bridge_routes',
      params: { apiBaseUrl },
    });
  };

  /**
   * Show dynamic info (networks + token list URL) in a Snap dialog.
   * Use the token list URL in MetaMask Settings → Token list to get tokens and icons.
   */
  const handleShowDynamicInfo = async () => {
    if (!apiBaseUrl) {
      return;
    }
    await invokeSnap({
      method: 'show_dynamic_info',
      params: { apiBaseUrl },
    });
  };

  /**
   *
   */
  const handleGetSwapQuote = async () => {
    if (!apiBaseUrl) {
      setSwapQuote({ error: 'Set GATSBY_SNAP_API_BASE_URL' });
      return;
    }
    if (!swapTokenIn || !swapTokenOut || !swapAmountIn) {
      setSwapQuote({ error: 'Enter tokenIn, tokenOut, and amountIn' });
      return;
    }
    try {
      const result = (await invokeSnap({
        method: 'get_swap_quote',
        params: {
          apiBaseUrl,
          chainId: 138,
          tokenIn: swapTokenIn.trim(),
          tokenOut: swapTokenOut.trim(),
          amountIn: swapAmountIn.trim(),
        },
      })) as {
        /**
         *
         */
        amountOut?: string;
        /**
         *
         */
        error?: string;
        /**
         *
         */
        poolAddress?: string | null;
      };
      setSwapQuote({
        amountOut: result?.amountOut,
        error: result?.error,
        poolAddress: result?.poolAddress,
      });
    } catch (e) {
      setSwapQuote({
        error: e instanceof Error ? e.message : 'Failed to fetch quote',
      });
    }
  };

  /**
   *
   */
  const handleShowSwapQuote = async () => {
    if (!apiBaseUrl || !swapTokenIn || !swapTokenOut || !swapAmountIn) {
      return;
    }
    await invokeSnap({
      method: 'show_swap_quote',
      params: {
        apiBaseUrl,
        chainId: 138,
        tokenIn: swapTokenIn.trim(),
        tokenOut: swapTokenOut.trim(),
        amountIn: swapAmountIn.trim(),
      },
    });
  };

  return (
    <Container>
      <Heading>
        Welcome to <Span>Chain 138 Snap</Span>
      </Heading>
      <Subtitle>
        Add Chain 138 (DeFi Oracle Meta) to MetaMask and use market data,
        bridge, and swap.
      </Subtitle>
      <Notice>
        <p>
          <strong>How to use:</strong> Install MetaMask (or MetaMask Flask for
          Snaps) → Connect your wallet → Install the Snap → Use the Market,
          Bridge, and Swap cards below (set GATSBY_SNAP_API_BASE_URL for
          production API).
        </p>
        <p style={{ marginTop: '1rem', marginBottom: 0 }}>
          <strong>Chain 138 Send:</strong> If MetaMask’s in-wallet
          &quot;Send&quot; errors with &quot;No XChain Swaps native asset
          found&quot;, use{' '}
          <a
            href={
              getSnapSiteUrl()
                ? `${getSnapSiteUrl()}${(typeof process !== 'undefined' && process.env?.GATSBY_PATH_PREFIX) || ''}/send`
                : './send'
            }
            style={{ color: 'var(--color-primary-default, #6F4CFF)' }}
          >
            Send on Chain 138
          </a>{' '}
          instead.
        </p>
      </Notice>
      <CardContainer>
        {error && (
          <ErrorMessage>
            <b>An error happened:</b> {error.message}
          </ErrorMessage>
        )}
        {!isMetaMaskReady && (
          <Card
            content={{
              title: 'Install',
              description:
                'Snaps is pre-release software only available in MetaMask Flask, a canary distribution for developers with access to upcoming features.',
              button: <InstallFlaskButton />,
            }}
            fullWidth
          />
        )}
        {!installedSnap && (
          <Card
            content={{
              title: 'Connect',
              description:
                'Get started by connecting to and installing the example snap.',
              button: (
                <ConnectButton
                  onClick={requestSnap}
                  disabled={!isMetaMaskReady}
                  label={isFlask ? 'Connect MetaMask Flask' : 'Connect'}
                />
              ),
            }}
            disabled={!isMetaMaskReady}
          />
        )}
        {shouldDisplayReconnectButton(installedSnap) && (
          <Card
            content={{
              title: 'Reconnect',
              description:
                'While connected to a local running snap this button will always be displayed in order to update the snap if a change is made.',
              button: (
                <ReconnectButton
                  onClick={requestSnap}
                  disabled={!installedSnap}
                />
              ),
            }}
            disabled={!installedSnap}
          />
        )}
        <Card
          content={{
            title: 'Send Hello message',
            description:
              'Display a custom message within a confirmation screen in MetaMask.',
            button: (
              <SendHelloButton
                onClick={handleSendHelloClick}
                disabled={!installedSnap}
              />
            ),
          }}
          disabled={!installedSnap}
          fullWidth={
            isMetaMaskReady &&
            Boolean(installedSnap) &&
            !shouldDisplayReconnectButton(installedSnap)
          }
        />
        <Card
          content={{
            title: 'Market data',
            description: apiBaseUrl
              ? 'Show token prices in a Snap dialog (from token-aggregation API).'
              : 'Set GATSBY_SNAP_API_BASE_URL to show market data.',
            button: (
              <Button
                onClick={handleShowMarketData}
                disabled={!installedSnap || !apiBaseUrl}
              >
                Show market data
              </Button>
            ),
          }}
          disabled={!installedSnap}
        />
        <Card
          content={{
            title: 'Market summary',
            description: apiBaseUrl
              ? 'Fetch token list with prices and display below.'
              : 'Set GATSBY_SNAP_API_BASE_URL to fetch market summary.',
            button: (
              <Button
                onClick={handleGetMarketSummary}
                disabled={!installedSnap || !apiBaseUrl}
              >
                Fetch market summary
              </Button>
            ),
          }}
          disabled={!installedSnap}
        />
        <Card
          content={{
            title: 'Bridge',
            description: apiBaseUrl
              ? 'Show CCIP and Trustless bridge routes in a Snap dialog. Use explorer for executing transfers.'
              : 'Set GATSBY_SNAP_API_BASE_URL to show bridge routes.',
            button: (
              <Button
                onClick={handleShowBridgeRoutes}
                disabled={!installedSnap || !apiBaseUrl}
              >
                Show bridge routes
              </Button>
            ),
          }}
          disabled={!installedSnap}
        />
        <Card
          content={{
            title: 'Token list URL',
            description: apiBaseUrl
              ? 'Show networks and token list URL. Add the URL in MetaMask Settings → Token list to display tokens and icons.'
              : 'Set GATSBY_SNAP_API_BASE_URL to get the token list URL.',
            button: (
              <Button
                onClick={handleShowDynamicInfo}
                disabled={!installedSnap || !apiBaseUrl}
              >
                Show dynamic info
              </Button>
            ),
          }}
          disabled={!installedSnap}
        />
        <Card
          fullWidth
          content={{
            title: 'Swap quote',
            description: apiBaseUrl ? (
              <div>
                <div style={{ marginBottom: '0.5rem' }}>
                  <input
                    type="text"
                    placeholder="Token In (address)"
                    value={swapTokenIn}
                    onChange={(e) => setSwapTokenIn(e.target.value)}
                    style={{ width: '100%', marginBottom: '0.25rem' }}
                  />
                  <input
                    type="text"
                    placeholder="Token Out (address)"
                    value={swapTokenOut}
                    onChange={(e) => setSwapTokenOut(e.target.value)}
                    style={{ width: '100%', marginBottom: '0.25rem' }}
                  />
                  <input
                    type="text"
                    placeholder="Amount In (raw)"
                    value={swapAmountIn}
                    onChange={(e) => setSwapAmountIn(e.target.value)}
                    style={{ width: '100%' }}
                  />
                </div>
                <div
                  style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}
                >
                  <Button
                    onClick={handleGetSwapQuote}
                    disabled={!installedSnap}
                  >
                    Get quote
                  </Button>
                  <Button
                    onClick={handleShowSwapQuote}
                    disabled={
                      !installedSnap ||
                      !swapTokenIn ||
                      !swapTokenOut ||
                      !swapAmountIn
                    }
                  >
                    Show quote in Snap
                  </Button>
                </div>
                {swapQuote && (
                  <div style={{ marginTop: '0.8rem', fontSize: '0.9rem' }}>
                    {swapQuote.error ? (
                      <span style={{ color: 'var(--color-error-default)' }}>
                        {swapQuote.error}
                      </span>
                    ) : (
                      <>
                        Amount Out: {swapQuote.amountOut ?? '—'}
                        {swapQuote.poolAddress && (
                          <> (pool: {swapQuote.poolAddress.slice(0, 10)}...)</>
                        )}
                      </>
                    )}
                  </div>
                )}
              </div>
            ) : (
              'Set GATSBY_SNAP_API_BASE_URL and enter token addresses + amount (raw).'
            ),
            button: null,
          }}
          disabled={!installedSnap}
        />
        {marketSummary && (
          <Card
            fullWidth
            content={{
              title: 'Market summary result',
              description: marketSummary.error ? (
                <span style={{ color: 'var(--color-error-default)' }}>
                  {marketSummary.error}
                </span>
              ) : (
                <MarketSummaryList>
                  {marketSummary.tokens.length === 0
                    ? 'No tokens.'
                    : marketSummary.tokens.map((t, i) => (
                        <div key={i}>
                          {t.symbol ?? t.name ?? 'Token'}
                          {t.market?.priceUsd != null &&
                            ` — $${Number(t.market.priceUsd).toFixed(4)}`}
                        </div>
                      ))}
                </MarketSummaryList>
              ),
            }}
          />
        )}
        <Notice>
          <p>
            When hosting the Snap yourself (e.g. for development),{' '}
            <b>snap.manifest.json</b> and <b>package.json</b> must be at the
            host’s root path, and the bundle must be served at the path given in{' '}
            <b>source.location</b> in the manifest. When installing from npm
            (production), the published package already satisfies this layout.
          </p>
        </Notice>
      </CardContainer>
    </Container>
  );
};

export default Index;
