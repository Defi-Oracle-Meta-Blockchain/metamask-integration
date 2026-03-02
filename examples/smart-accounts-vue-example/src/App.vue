<template>
  <div class="app">
    <header class="app-header">
      <h1>Smart Accounts Example</h1>
      <p>ChainID 138 - SMOM-DBIS-138</p>
    </header>

    <main class="app-main">
      <div v-if="error" class="error">
        <strong>Error:</strong> {{ error }}
      </div>

      <div v-if="!userAddress" class="section">
        <h2>Connect Wallet</h2>
        <button @click="connectWallet" :disabled="loading || !provider">
          {{ loading ? 'Connecting...' : 'Connect MetaMask' }}
        </button>
      </div>

      <template v-else>
        <div class="section">
          <h2>Wallet Connected</h2>
          <p><strong>Address:</strong> {{ userAddress }}</p>
        </div>

        <div v-if="!smartAccount" class="section">
          <h2>Create Smart Account</h2>
          <button @click="createSmartAccount" :disabled="loading">
            {{ loading ? 'Creating...' : 'Create Smart Account' }}
          </button>
        </div>

        <template v-else>
          <div class="section">
            <h2>Smart Account</h2>
            <p><strong>Address:</strong> {{ smartAccount.address }}</p>
            <p><strong>Owner:</strong> {{ smartAccount.owner }}</p>
          </div>

          <div class="section">
            <h2>Delegations</h2>
            <button @click="requestDelegation" :disabled="loading">
              {{ loading ? 'Requesting...' : 'Request Delegation' }}
            </button>
            <ul v-if="delegations.length > 0">
              <li v-for="(delegation, index) in delegations" :key="index">
                <strong>Target:</strong> {{ delegation.target }}<br />
                <strong>Active:</strong> {{ delegation.active ? 'Yes' : 'No' }}<br />
                <strong>Expires:</strong> {{ new Date(delegation.expiry).toLocaleString() }}
              </li>
            </ul>
          </div>
        </template>
      </template>
    </main>

    <footer class="app-footer">
      <p>
        See <a href="../../docs/SMART_ACCOUNTS_DEVELOPER_GUIDE.md">Developer Guide</a> for more information.
      </p>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { SmartAccountsKit } from '@metamask/smart-accounts-kit';
import { ethers } from 'ethers';

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

const provider = ref<ethers.BrowserProvider | null>(null);
const signer = ref<ethers.JsonRpcSigner | null>(null);
const userAddress = ref<string>('');
const smartAccount = ref<SmartAccount | null>(null);
const smartAccountsKit = ref<SmartAccountsKit | null>(null);
const delegations = ref<Delegation[]>([]);
const loading = ref(false);
const error = ref<string | null>(null);

// Initialize MetaMask connection
onMounted(() => {
  if (window.ethereum) {
    const initProvider = new ethers.BrowserProvider(window.ethereum);
    provider.value = initProvider;
    
    // Initialize Smart Accounts Kit
    const kit = new SmartAccountsKit({
      chainId: config.chainId,
      rpcUrl: config.rpcUrl,
      entryPointAddress: config.entryPointAddress,
      accountFactoryAddress: config.accountFactoryAddress,
      paymasterAddress: config.paymasterAddress || undefined,
    });
    smartAccountsKit.value = kit;
  } else {
    error.value = 'MetaMask is not installed';
  }
});

// Connect to MetaMask
const connectWallet = async () => {
  if (!provider.value) return;
  
  try {
    loading.value = true;
    error.value = null;
    
    const accounts = await provider.value.send('eth_requestAccounts', []);
    const signerInstance = await provider.value.getSigner();
    const address = await signerInstance.getAddress();
    
    signer.value = signerInstance;
    userAddress.value = address;
  } catch (err: any) {
    error.value = err.message || 'Failed to connect wallet';
  } finally {
    loading.value = false;
  }
};

// Create Smart Account
const createSmartAccount = async () => {
  if (!smartAccountsKit.value || !userAddress.value) return;
  
  try {
    loading.value = true;
    error.value = null;
    
    const account = await smartAccountsKit.value.createAccount({
      owner: userAddress.value,
    });
    
    smartAccount.value = {
      address: account.address,
      owner: userAddress.value,
    };
  } catch (err: any) {
    error.value = err.message || 'Failed to create smart account';
  } finally {
    loading.value = false;
  }
};

// Request Delegation
const requestDelegation = async () => {
  if (!smartAccountsKit.value || !smartAccount.value) return;
  
  try {
    loading.value = true;
    error.value = null;
    
    const delegation = await smartAccountsKit.value.requestDelegation({
      target: '0x...', // Replace with actual target
      permissions: ['execute_transactions', 'batch_operations'],
      expiry: Date.now() + 86400000, // 24 hours
    });
    
    if (delegation.approved) {
      // Refresh delegations
      await loadDelegations();
    }
  } catch (err: any) {
    error.value = err.message || 'Failed to request delegation';
  } finally {
    loading.value = false;
  }
};

// Load Delegations
const loadDelegations = async () => {
  if (!smartAccountsKit.value || !smartAccount.value) return;
  
  try {
    // This would typically fetch from your backend or contract
    // For demo purposes, we'll use a placeholder
    const status = await smartAccountsKit.value.getDelegationStatus({
      target: '0x...', // Replace with actual target
      account: smartAccount.value.address,
    });
    
    // Update delegations state
    // Implementation depends on your delegation storage
  } catch (err: any) {
    console.error('Failed to load delegations:', err);
  }
};
</script>

<style scoped>
.app {
  text-align: center;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-header {
  background-color: #282c34;
  padding: 20px;
  color: white;
}

.app-main {
  flex: 1;
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
  width: 100%;
}

.section {
  background: #f5f5f5;
  border-radius: 8px;
  padding: 20px;
  margin: 20px 0;
  text-align: left;
}

.section h2 {
  margin-top: 0;
  color: #333;
}

.section p {
  margin: 10px 0;
  word-break: break-all;
}

button {
  background-color: #4CAF50;
  border: none;
  color: white;
  padding: 12px 24px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  margin: 10px 0;
  cursor: pointer;
  border-radius: 4px;
  transition: background-color 0.3s;
}

button:hover:not(:disabled) {
  background-color: #45a049;
}

button:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

.error {
  background-color: #f44336;
  color: white;
  padding: 15px;
  border-radius: 4px;
  margin: 20px 0;
}

.app-footer {
  background-color: #282c34;
  padding: 20px;
  color: white;
}

.app-footer a {
  color: #61dafb;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  background: white;
  padding: 15px;
  margin: 10px 0;
  border-radius: 4px;
  text-align: left;
}
</style>
