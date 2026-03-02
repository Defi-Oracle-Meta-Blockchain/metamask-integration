<template>
  <div class="app">
    <div class="container">
      <h1>MetaMask ChainID 138 Vue Example</h1>
      
      <div v-if="!isMetaMaskInstalled" class="error">
        MetaMask is not installed. Please install MetaMask extension.
      </div>

      <div v-if="error" class="error">
        {{ error }}
      </div>

      <div v-if="!isConnected">
        <button @click="connectWallet" class="btn btn-primary">
          Connect Wallet
        </button>
      </div>

      <div v-else class="wallet-info">
        <h2>Wallet Connected</h2>
        <p><strong>Account:</strong> {{ account }}</p>
        <p><strong>Chain ID:</strong> {{ chainId }}</p>
        <p><strong>Balance:</strong> {{ balance }} ETH</p>

        <div v-if="!isOnChain138" class="network-section">
          <h3>Network Setup</h3>
          <button @click="addChain138" class="btn btn-secondary">
            Add ChainID 138
          </button>
          <button @click="switchToChain138" class="btn btn-secondary">
            Switch to ChainID 138
          </button>
        </div>

        <div v-if="isOnChain138" class="tokens-section">
          <h3>Add Tokens</h3>
          <button @click="addToken('cUSDT', tokens.cUSDT, 6)" class="btn btn-token">
            Add cUSDT
          </button>
          <button @click="addToken('cUSDC', tokens.cUSDC, 6)" class="btn btn-token">
            Add cUSDC
          </button>
          <button @click="addToken('WETH', tokens.WETH, 18)" class="btn btn-token">
            Add WETH
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { ethers } from 'ethers';

// ChainID 138 Network Configuration
const CHAIN_138_CONFIG = {
  chainId: '0x8a',
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
const tokens = {
  cUSDT: '0x93E66202A11B1772E55407B32B44e5Cd8eda7f22',
  cUSDC: '0xf22258f57794CC8E06237084b353Ab30fFfa640b',
  WETH: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
};

const account = ref<string | null>(null);
const chainId = ref<string | null>(null);
const balance = ref<string>('0');
const isConnected = ref(false);
const error = ref<string | null>(null);

const isMetaMaskInstalled = typeof window.ethereum !== 'undefined';
const isOnChain138 = computed(() => chainId.value === '138');

const connectWallet = async () => {
  if (!isMetaMaskInstalled) {
    error.value = 'MetaMask is not installed. Please install MetaMask extension.';
    return;
  }

  try {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const accounts = await provider.send('eth_requestAccounts', []);
    
    if (accounts.length > 0) {
      account.value = accounts[0];
      isConnected.value = true;
      error.value = null;
      
      const network = await provider.getNetwork();
      chainId.value = network.chainId.toString();
      
      const bal = await provider.getBalance(accounts[0]);
      balance.value = ethers.formatEther(bal);
    }
  } catch (err: any) {
    error.value = err.message || 'Failed to connect wallet';
  }
};

const addChain138 = async () => {
  if (!isMetaMaskInstalled) {
    error.value = 'MetaMask is not installed';
    return;
  }

  try {
    await window.ethereum.request({
      method: 'wallet_addEthereumChain',
      params: [CHAIN_138_CONFIG],
    });
    error.value = null;
  } catch (err: any) {
    error.value = err.message || 'Failed to add network';
  }
};

const switchToChain138 = async () => {
  if (!isMetaMaskInstalled) {
    error.value = 'MetaMask is not installed';
    return;
  }

  try {
    await window.ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: CHAIN_138_CONFIG.chainId }],
    });
    error.value = null;
    
    const provider = new ethers.BrowserProvider(window.ethereum);
    const network = await provider.getNetwork();
    chainId.value = network.chainId.toString();
  } catch (err: any) {
    if ((err as any).code === 4902) {
      await addChain138();
    } else {
      error.value = (err as any).message || 'Failed to switch network';
    }
  }
};

const addToken = async (symbol: string, address: string, decimals: number) => {
  if (!isMetaMaskInstalled) {
    error.value = 'MetaMask is not installed';
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
    error.value = null;
  } catch (err: any) {
    error.value = err.message || 'Failed to add token';
  }
};
</script>

<style scoped>
.app {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
}

.container {
  background: white;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  padding: 40px;
  max-width: 600px;
  width: 100%;
}

h1 {
  color: #333;
  margin-bottom: 20px;
  font-size: 28px;
}

h2 {
  color: #333;
  margin-bottom: 15px;
  font-size: 22px;
}

h3 {
  color: #555;
  margin-bottom: 10px;
  font-size: 18px;
}

.wallet-info {
  margin-top: 20px;
}

.wallet-info p {
  margin: 10px 0;
  color: #666;
}

.network-section,
.tokens-section {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #eee;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  margin: 5px;
}

.btn-primary {
  background: #667eea;
  color: white;
}

.btn-primary:hover {
  background: #5568d3;
}

.btn-secondary {
  background: #48bb78;
  color: white;
}

.btn-secondary:hover {
  background: #38a169;
}

.btn-token {
  background: #ed8936;
  color: white;
}

.btn-token:hover {
  background: #dd6b20;
}

.error {
  background: #fed7d7;
  color: #c53030;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 20px;
}
</style>
