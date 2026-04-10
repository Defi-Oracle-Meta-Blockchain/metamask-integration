/**
 * Send page — Chain 138 native send (bypasses MetaMask's broken Send UI).
 *
 * MetaMask's in-wallet "Send" can throw "No XChain Swaps native asset found for chainId: eip155:138"
 * because Chain 138 is not in their LavaPack list. This page sends via eth_sendTransaction from the
 * dApp context, which uses a different code path and works on Chain 138.
 */

import { useState } from 'react';
import styled from 'styled-components';

import { Button } from '../components';
import { useMetaMaskContext } from '../hooks/MetamaskContext';

const CHAIN_ID_138_HEX = '0x8a';
const CHAIN_138_PARAMS = {
  chainId: CHAIN_ID_138_HEX,
  chainName: 'DeFi Oracle Meta Mainnet',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: ['https://rpc-http-pub.d-bis.org'],
  blockExplorerUrls: ['https://explorer.d-bis.org', 'https://blockscout.defi-oracle.io'],
};

const Container = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  max-width: 32rem;
  margin: 4rem auto;
  padding: 0 2.4rem;
  ${({ theme }) => theme.mediaQueries?.small} {
    margin: 2rem auto;
    padding: 0 1.2rem;
  }
`;

const Title = styled.h1`
  margin: 0 0 0.5rem;
  font-size: ${({ theme }) => theme.fontSizes?.title ?? '1.5rem'};
`;

const Subtitle = styled.p`
  margin: 0 0 2rem;
  color: ${({ theme }) => theme.colors?.text?.alternative};
  font-size: ${({ theme }) => theme.fontSizes?.small};
`;

const Form = styled.form`
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
`;

const Label = styled.label`
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  font-size: ${({ theme }) => theme.fontSizes?.small};
  font-weight: 500;
`;

const Input = styled.input`
  padding: 0.8rem 1rem;
  border: 1px solid ${({ theme }) => theme.colors?.border?.default};
  border-radius: ${({ theme }) => theme.radii?.default ?? '6px'};
  font-size: ${({ theme }) => theme.fontSizes?.text};
  background: ${({ theme }) => theme.colors?.background?.default};
  color: ${({ theme }) => theme.colors?.text?.default};
  font-family: inherit;

  &::placeholder {
    color: ${({ theme }) => theme.colors?.text?.muted};
  }
`;

const Message = styled.div<{
  /**
   *
   */
  $error?: boolean;
}>`
  padding: 1rem;
  border-radius: ${({ theme }) => theme.radii?.default ?? '6px'};
  font-size: ${({ theme }) => theme.fontSizes?.small};
  background: ${({ theme, $error }) =>
    $error
      ? theme.colors?.error?.muted
      : theme.colors?.background?.alternative};
  color: ${({ theme, $error }) =>
    $error ? theme.colors?.error?.default : theme.colors?.text?.default};
  word-break: break-all;
`;

const Row = styled.div`
  display: flex;
  gap: 0.8rem;
  flex-wrap: wrap;
`;

const StyledButton = styled(Button)`
  flex: 1;
  min-width: 8rem;
`;

const BackLink = styled.a`
  margin-top: 2rem;
  font-size: ${({ theme }) => theme.fontSizes?.small};
  color: ${({ theme }) => theme.colors?.primary?.default};
  text-decoration: none;

  &:hover {
    text-decoration: underline;
  }
`;

/**
 *
 * @param eth
 */
function ethToWeiHex(eth: string): string {
  const parsed = parseFloat(eth);
  if (Number.isNaN(parsed) || parsed < 0) {
    return '0x0';
  }
  const wei = BigInt(Math.floor(parsed * 1e18));
  return `0x${wei.toString(16)}`;
}

/**
 *
 * @param addr
 */
function isValidAddress(addr: string): boolean {
  return /^0x[a-fA-F0-9]{40}$/.test(addr.trim());
}

/**
 *
 */
export default function SendPage() {
  const { provider } = useMetaMaskContext();
  const [to, setTo] = useState('');
  const [amount, setAmount] = useState('');
  const [message, setMessage] = useState<{
    /**
     *
     */
    text: string;
    /**
     *
     */
    error?: boolean;
  } | null>(null);
  const [loading, setLoading] = useState(false);

  /**
   *
   */
  const ensureChain138 = async (): Promise<boolean> => {
    if (!provider) {
      setMessage({
        text: 'MetaMask not detected. Install and connect MetaMask.',
        error: true,
      });
      return false;
    }
    try {
      await provider.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: CHAIN_ID_138_HEX }],
      });
      return true;
    } catch (err: unknown) {
      const code = (
        err as {
          /**
           *
           */
          code?: number;
        }
      )?.code;
      if (code === 4902) {
        try {
          await provider.request({
            method: 'wallet_addEthereumChain',
            params: [CHAIN_138_PARAMS],
          });
          return true;
        } catch (addErr) {
          setMessage({
            text: `Failed to add Chain 138: ${addErr instanceof Error ? addErr.message : String(addErr)}`,
            error: true,
          });
          return false;
        }
      }
      setMessage({
        text: `Failed to switch to Chain 138: ${err instanceof Error ? err.message : String(err)}`,
        error: true,
      });
      return false;
    }
  };

  /**
   *
   */
  const handleSwitchChain = async () => {
    setMessage(null);
    setLoading(true);
    const ok = await ensureChain138();
    setLoading(false);
    if (ok) {
      setMessage({ text: 'Switched to Chain 138.' });
    }
  };

  /**
   *
   * @param e
   */
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage(null);
    if (!provider) {
      setMessage({ text: 'MetaMask not detected.', error: true });
      return;
    }
    const toAddress = to.trim();
    if (!isValidAddress(toAddress)) {
      setMessage({ text: 'Enter a valid 0x address.', error: true });
      return;
    }
    const amountNum = parseFloat(amount);
    if (Number.isNaN(amountNum) || amountNum <= 0) {
      setMessage({ text: 'Enter a valid amount (ETH).', error: true });
      return;
    }
    const ok = await ensureChain138();
    if (!ok) {
      return;
    }

    setLoading(true);
    try {
      const accounts = (await provider.request({
        method: 'eth_requestAccounts',
        params: [],
      })) as string[];
      const from = accounts?.[0];
      if (!from) {
        setMessage({ text: 'No account selected in MetaMask.', error: true });
        setLoading(false);
        return;
      }
      const txHash = (await provider.request({
        method: 'eth_sendTransaction',
        params: [
          {
            from,
            to: toAddress,
            value: ethToWeiHex(amount),
            gasLimit: '0x5208', // 21000 for simple transfer
          },
        ],
      })) as string;
      setMessage({
        text: `Sent. Tx: ${txHash}. Confirm in MetaMask and check the block explorer.`,
      });
      setTo('');
      setAmount('');
    } catch (err) {
      setMessage({
        text: err instanceof Error ? err.message : String(err),
        error: true,
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container>
      <Title>Send on Chain 138</Title>
      <Subtitle>
        Use this page to send ETH on Chain 138. It bypasses MetaMask’s in-wallet
        Send button, which errors on custom chains.
      </Subtitle>
      <Form onSubmit={handleSubmit}>
        <Label>
          Recipient address
          <Input
            type="text"
            placeholder="0x..."
            value={to}
            onChange={(e) => setTo(e.target.value)}
            disabled={loading}
          />
        </Label>
        <Label>
          Amount (ETH)
          <Input
            type="text"
            inputMode="decimal"
            placeholder="0.1"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            disabled={loading}
          />
        </Label>
        {message && <Message $error={message.error}>{message.text}</Message>}
        <Row>
          <StyledButton
            type="button"
            onClick={handleSwitchChain}
            disabled={loading || !provider}
          >
            {loading ? '…' : 'Switch to Chain 138'}
          </StyledButton>
          <StyledButton type="submit" disabled={loading || !provider}>
            {loading ? '…' : 'Send'}
          </StyledButton>
        </Row>
      </Form>
      <BackLink href="./">← Back to Chain 138 Snap</BackLink>
    </Container>
  );
}
