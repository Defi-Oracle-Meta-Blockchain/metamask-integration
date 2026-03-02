import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import './App.css';

// ChainID 138 Network Configuration
const CHAIN_138_CONFIG = {
  chainId: '0x8a', // 138 in hex
  chainName: 'DeFi Oracle Meta Mainnet',
  nativeCurrency: {
    name: 'Ether',
    symbol: 'ETH',
    decimals: 18,
  },
  rpcUrls: ['https://rpc.d-bis.org', 'https://rpc2.d-bis.org'],
  blockExplorerUrls: ['https://explorer.d-bis.org'],
};

// Token addresses
const TOKENS = {
  cUSDT: '0x93E66202A11B1772E55407B32B44e5Cd8eda7f22',
  cUSDC: '0xf22258f57794CC8E06237084b353Ab30fFfa640b',
  WETH: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
};

function App() {
  const [account, setAccount] = useState<string | null>(null);
  const [chainId, setChainId] = useState<string | null>(null);
  const [balance, setBalance] = useState<string>('0');
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Check if MetaMask is installed
  const isMetaMaskInstalled = typeof window.ethereum !== 'undefined';

  // Connect to MetaMask
  const connectWallet = async () => {
    if (!isMetaMaskInstalled) {
      setError('MetaMask is not installed. Please install MetaMask extension.');
      return;
    }

    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      const accounts = await provider.send('eth_requestAccounts', []);
      
      if (accounts.length > 0) {
        setAccount(accounts[0]);
        setIsConnected(true);
        setError(null);
        
        // Get chain ID
        const network = await provider.getNetwork();
        setChainId(network.chainId.toString());
        
        // Get balance
        const balance = await provider.getBalance(accounts[0]);
        setBalance(ethers.formatEther(balance));
      }
    } catch (err: any) {
      setError(err.message || 'Failed to connect wallet');
    }
  };

  // Add ChainID 138 to MetaMask
  const addChain138 = async () => {
    if (!isMetaMaskInstalled) {
      setError('MetaMask is not installed');
      return;
    }

    try {
      await window.ethereum.request({
        method: 'wallet_addEthereumChain',
        params: [CHAIN_138_CONFIG],
      });
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to add network');
    }
  };

  // Switch to ChainID 138
  const switchToChain138 = async () => {
    if (!isMetaMaskInstalled) {
      setError('MetaMask is not installed');
      return;
    }

    try {
      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: CHAIN_138_CONFIG.chainId }],
      });
      setError(null);
      
      // Refresh connection
      const provider = new ethers.BrowserProvider(window.ethereum);
      const network = await provider.getNetwork();
      setChainId(network.chainId.toString());
    } catch (err: any) {
      // If chain is not added, try to add it
      if ((err as any).code === 4902) {
        await addChain138();
      } else {
        setError((err as any).message || 'Failed to switch network');
      }
    }
  };

  // Add token to MetaMask
  const addToken = async (symbol: string, address: string, decimals: number) => {
    if (!isMetaMaskInstalled) {
      setError('MetaMask is not installed');
      return;
    }

    try {
      await window.ethereum.request({
        method: 'wallet_watchAsset',
        params: {
          type: 'ERC20',
          options: {
            address: address,
            symbol: symbol,
            decimals: decimals,
          },
        },
      });
      setError(null);
    } catch (err: any) {
      setError(err.message || 'Failed to add token');
    }
  };

  // Check if on ChainID 138
  const isOnChain138 = chainId === '138';

  return (
    <div className="app">
      <div className="container">
        <h1>MetaMask ChainID 138 Example</h1>
        
        {!isMetaMaskInstalled && (
          <div className="error">
            MetaMask is not installed. Please install MetaMask extension.
          </div>
        )}

        {error && (
          <div className="error">
            {error}
          </div>
        )}

        {!isConnected ? (
          <button onClick={connectWallet} className="btn btn-primary">
            Connect Wallet
          </button>
        ) : (
          <div className="wallet-info">
            <h2>Wallet Connected</h2>
            <p><strong>Account:</strong> {account}</p>
            <p><strong>Chain ID:</strong> {chainId}</p>
            <p><strong>Balance:</strong> {parseFloat(balance).toFixed(4)} ETH</p>

            {!isOnChain138 && (
              <div className="network-section">
                <h3>Network Setup</h3>
                <button onClick={addChain138} className="btn btn-secondary">
                  Add ChainID 138
                </button>
                <button onClick={switchToChain138} className="btn btn-secondary">
                  Switch to ChainID 138
                </button>
              </div>
            )}

            {isOnChain138 && (
              <div className="tokens-section">
                <h3>Add Tokens</h3>
                <button 
                  onClick={() => addToken('cUSDT', TOKENS.cUSDT, 6)} 
                  className="btn btn-token"
                >
                  Add cUSDT
                </button>
                <button 
                  onClick={() => addToken('cUSDC', TOKENS.cUSDC, 6)} 
                  className="btn btn-token"
                >
                  Add cUSDC
                </button>
                <button 
                  onClick={() => addToken('WETH', TOKENS.WETH, 18)} 
                  className="btn btn-token"
                >
                  Add WETH
                </button>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

export default App;
