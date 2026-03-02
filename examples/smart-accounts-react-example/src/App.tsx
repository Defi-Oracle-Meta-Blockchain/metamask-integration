/**
 * Smart Accounts React Example
 * 
 * Complete React example demonstrating Smart Accounts Kit integration
 */

import React, { useState, useEffect } from 'react';
import { SmartAccountsKit } from '@metamask/smart-accounts-kit';
import { ethers } from 'ethers';
import './App.css';

// Load configuration
const config = require('../../config/smart-accounts-config.json');

interface SmartAccount {
  address: string;
  owner: string;
}

interface Delegation {
  target: string;
  active: boolean;
  expiry: number;
  permissions: string[];
}

function App() {
  const [provider, setProvider] = useState<ethers.BrowserProvider | null>(null);
  const [signer, setSigner] = useState<ethers.JsonRpcSigner | null>(null);
  const [userAddress, setUserAddress] = useState<string>('');
  const [smartAccount, setSmartAccount] = useState<SmartAccount | null>(null);
  const [smartAccountsKit, setSmartAccountsKit] = useState<SmartAccountsKit | null>(null);
  const [delegations, setDelegations] = useState<Delegation[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Initialize MetaMask connection
  useEffect(() => {
    if (window.ethereum) {
      const initProvider = new ethers.BrowserProvider(window.ethereum);
      setProvider(initProvider);
      
      // Initialize Smart Accounts Kit
      const kit = new SmartAccountsKit({
        chainId: config.chainId,
        rpcUrl: config.rpcUrl,
        entryPointAddress: config.entryPointAddress,
        accountFactoryAddress: config.accountFactoryAddress,
        paymasterAddress: config.paymasterAddress || undefined,
      });
      setSmartAccountsKit(kit);
    } else {
      setError('MetaMask is not installed');
    }
  }, []);

  // Connect to MetaMask
  const connectWallet = async () => {
    if (!provider) return;
    
    try {
      setLoading(true);
      setError(null);
      
      const accounts = await provider.send('eth_requestAccounts', []);
      const signer = await provider.getSigner();
      const address = await signer.getAddress();
      
      setSigner(signer);
      setUserAddress(address);
    } catch (err: any) {
      setError(err.message || 'Failed to connect wallet');
    } finally {
      setLoading(false);
    }
  };

  // Create Smart Account
  const createSmartAccount = async () => {
    if (!smartAccountsKit || !userAddress) return;
    
    try {
      setLoading(true);
      setError(null);
      
      const account = await smartAccountsKit.createAccount({
        owner: userAddress,
      });
      
      setSmartAccount({
        address: account.address,
        owner: userAddress,
      });
    } catch (err: any) {
      setError(err.message || 'Failed to create smart account');
    } finally {
      setLoading(false);
    }
  };

  // Request Delegation
  const requestDelegation = async (target: string) => {
    if (!smartAccountsKit || !smartAccount) return;
    
    try {
      setLoading(true);
      setError(null);
      
      const delegation = await smartAccountsKit.requestDelegation({
        target: target,
        permissions: ['execute_transactions', 'batch_operations'],
        expiry: Date.now() + 86400000, // 24 hours
      });
      
      if (delegation.approved) {
        // Refresh delegations
        await loadDelegations();
      }
    } catch (err: any) {
      setError(err.message || 'Failed to request delegation');
    } finally {
      setLoading(false);
    }
  };

  // Load Delegations
  const loadDelegations = async () => {
    if (!smartAccountsKit || !smartAccount) return;
    
    try {
      // This would typically fetch from your backend or contract
      // For demo purposes, we'll use a placeholder
      const status = await smartAccountsKit.getDelegationStatus({
        target: '0x...', // Replace with actual target
        account: smartAccount.address,
      });
      
      // Update delegations state
      // Implementation depends on your delegation storage
    } catch (err: any) {
      console.error('Failed to load delegations:', err);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Smart Accounts Example</h1>
        <p>ChainID 138 - SMOM-DBIS-138</p>
      </header>

      <main className="App-main">
        {error && (
          <div className="error">
            <strong>Error:</strong> {error}
          </div>
        )}

        {!userAddress ? (
          <div className="section">
            <h2>Connect Wallet</h2>
            <button onClick={connectWallet} disabled={loading || !provider}>
              {loading ? 'Connecting...' : 'Connect MetaMask'}
            </button>
          </div>
        ) : (
          <>
            <div className="section">
              <h2>Wallet Connected</h2>
              <p><strong>Address:</strong> {userAddress}</p>
            </div>

            {!smartAccount ? (
              <div className="section">
                <h2>Create Smart Account</h2>
                <button onClick={createSmartAccount} disabled={loading}>
                  {loading ? 'Creating...' : 'Create Smart Account'}
                </button>
              </div>
            ) : (
              <>
                <div className="section">
                  <h2>Smart Account</h2>
                  <p><strong>Address:</strong> {smartAccount.address}</p>
                  <p><strong>Owner:</strong> {smartAccount.owner}</p>
                </div>

                <div className="section">
                  <h2>Delegations</h2>
                  <button onClick={() => requestDelegation('0x...')} disabled={loading}>
                    {loading ? 'Requesting...' : 'Request Delegation'}
                  </button>
                  {delegations.length > 0 && (
                    <ul>
                      {delegations.map((delegation, index) => (
                        <li key={index}>
                          <strong>Target:</strong> {delegation.target}<br />
                          <strong>Active:</strong> {delegation.active ? 'Yes' : 'No'}<br />
                          <strong>Expires:</strong> {new Date(delegation.expiry).toLocaleString()}
                        </li>
                      ))}
                    </ul>
                  )}
                </div>
              </>
            )}
          </>
        )}
      </main>

      <footer className="App-footer">
        <p>
          See <a href="../../docs/SMART_ACCOUNTS_DEVELOPER_GUIDE.md">Developer Guide</a> for more information.
        </p>
      </footer>
    </div>
  );
}

export default App;
