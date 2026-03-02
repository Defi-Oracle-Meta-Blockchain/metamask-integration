/**
 * Smart Accounts Example
 * 
 * Complete example demonstrating Smart Accounts Kit usage
 */

import { SmartAccountsKit } from '@metamask/smart-accounts-kit';
import { ethers } from 'ethers';

// Load configuration
const config = require('../config/smart-accounts-config.json');

// Initialize Smart Accounts Kit
const smartAccountsKit = new SmartAccountsKit({
  chainId: config.chainId,
  rpcUrl: config.rpcUrl,
  entryPointAddress: config.entryPointAddress,
  accountFactoryAddress: config.accountFactoryAddress,
  paymasterAddress: config.paymasterAddress || undefined,
});

// Example 1: Create Smart Account
async function createSmartAccount() {
  console.log('Creating Smart Account...');
  
  // Get user address from MetaMask
  const provider = new ethers.BrowserProvider(window.ethereum);
  const signer = await provider.getSigner();
  const userAddress = await signer.getAddress();
  
  // Create Smart Account
  const smartAccount = await smartAccountsKit.createAccount({
    owner: userAddress,
  });
  
  console.log('Smart Account created:', smartAccount.address);
  return smartAccount;
}

// Example 2: Request Delegation
async function requestDelegation(smartAccountAddress: string, dAppAddress: string) {
  console.log('Requesting delegation...');
  
  const delegation = await smartAccountsKit.requestDelegation({
    target: dAppAddress,
    permissions: ['execute_transactions', 'batch_operations'],
    expiry: Date.now() + 86400000, // 24 hours
  });
  
  if (delegation.approved) {
    console.log('Delegation approved!');
  } else {
    console.log('Delegation rejected');
  }
  
  return delegation;
}

// Example 3: Check Delegation Status
async function checkDelegation(smartAccountAddress: string, dAppAddress: string) {
  console.log('Checking delegation status...');
  
  const status = await smartAccountsKit.getDelegationStatus({
    target: dAppAddress,
    account: smartAccountAddress,
  });
  
  console.log('Active:', status.active);
  console.log('Expires:', new Date(status.expiry));
  console.log('Permissions:', status.permissions);
  
  return status;
}

// Example 4: Request Advanced Permission
async function requestPermission(
  smartAccountAddress: string,
  contractAddress: string,
  functionSelector: string
) {
  console.log('Requesting permission...');
  
  const permission = await smartAccountsKit.requestAdvancedPermission({
    target: contractAddress,
    functionSelector: functionSelector,
    allowed: true,
  });
  
  if (permission.approved) {
    console.log('Permission granted!');
  } else {
    console.log('Permission denied');
  }
  
  return permission;
}

// Example 5: Batch User Operations
async function batchOperations(smartAccountAddress: string) {
  console.log('Creating batch operations...');
  
  const userOps = await smartAccountsKit.batchUserOperations([
    {
      to: '0x...', // Token address
      data: '0x...', // Transfer data
      value: '0',
    },
    {
      to: '0x...', // Another address
      data: '0x...', // Another operation
      value: '0',
    },
  ]);
  
  console.log('Batch created:', userOps.length, 'operations');
  
  // Execute batch
  const result = await smartAccountsKit.executeBatch(userOps);
  console.log('Transaction hash:', result.hash);
  
  return result;
}

// Example 6: Link Smart Account to Fiat Account
async function linkToFiatAccount(smartAccountAddress: string, accountRefId: string) {
  console.log('Linking Smart Account to fiat account...');
  
  // This would typically be done by account manager via AccountWalletRegistryExtended
  // Example using ethers:
  const provider = new ethers.BrowserProvider(window.ethereum);
  const signer = await provider.getSigner();
  
  const registry = new ethers.Contract(
    '0x...', // AccountWalletRegistryExtended address
    [
      'function linkSmartAccount(bytes32 accountRefId, address smartAccount, bytes32 provider)',
    ],
    signer
  );
  
  const tx = await registry.linkSmartAccount(
    accountRefId,
    smartAccountAddress,
    ethers.id('METAMASK_SMART_ACCOUNT')
  );
  
  await tx.wait();
  console.log('Smart Account linked!');
}

// Complete Example Flow
async function completeExample() {
  try {
    // 1. Create Smart Account
    const account = await createSmartAccount();
    
    // 2. Request Delegation
    const dAppAddress = '0x...'; // Your dApp address
    await requestDelegation(account.address, dAppAddress);
    
    // 3. Check Delegation Status
    await checkDelegation(account.address, dAppAddress);
    
    // 4. Request Permission
    const contractAddress = '0x...'; // Contract address
    const functionSelector = '0xa9059cbb'; // transfer(address,uint256)
    await requestPermission(account.address, contractAddress, functionSelector);
    
    // 5. Batch Operations
    await batchOperations(account.address);
    
    console.log('All examples completed successfully!');
  } catch (error) {
    console.error('Error:', error);
  }
}

// Export for use in other files
export {
  createSmartAccount,
  requestDelegation,
  checkDelegation,
  requestPermission,
  batchOperations,
  linkToFiatAccount,
  completeExample,
};
