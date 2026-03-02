# Community Support Setup Guide

Complete guide for setting up community support channels for MetaMask integration with ChainID 138.

## Overview

This guide covers setting up support channels, documentation, and processes to help users with MetaMask integration on ChainID 138.

---

## Support Channels

### 1. Discord Server

**Setup**:
1. Create Discord server
2. Set up channels:
   - `#general` - General discussion
   - `#support` - User support
   - `#developers` - Developer support
   - `#announcements` - Updates and announcements
   - `#feedback` - Feature requests and feedback

**Configuration**:
- Bot for automated responses
- Role-based permissions
- Moderation tools
- FAQ bot

**Invite Link**: [To be created]

---

### 2. GitHub Discussions

**Setup**:
1. Enable GitHub Discussions in repository
2. Create categories:
   - Q&A
   - General Discussion
   - Ideas
   - Show and Tell

**Benefits**:
- Integrated with codebase
- Searchable
- Version controlled
- Developer-friendly

**Repository**: [GitHub repo URL]

---

### 3. Telegram Group

**Setup**:
1. Create Telegram group
2. Set up bot for moderation
3. Create pinned messages with FAQs
4. Set up rules and guidelines

**Configuration**:
- Admin roles
- Moderation bot
- Welcome message
- FAQ bot

**Invite Link**: [To be created]

---

### 4. Support Email

**Setup**:
1. Create support email: `support@d-bis.org`
2. Set up email ticketing system
3. Configure auto-responders
4. Set up email templates

**Templates**:
- Welcome email
- Acknowledgment email
- Resolution email
- Follow-up email

---

### 5. Documentation Site

**Setup**:
1. Create documentation site
2. Organize by topic:
   - Getting Started
   - User Guides
   - Developer Guides
   - Troubleshooting
   - FAQ

**Platform Options**:
- GitHub Pages
- GitBook
- Docusaurus
- Read the Docs

---

## FAQ Document

### Common Questions

#### Q: How do I add ChainID 138 to MetaMask?

**A**: 
1. Open MetaMask
2. Click network dropdown
3. Click "Add Network"
4. Enter network details:
   - Network Name: DeFi Oracle Meta Mainnet
   - RPC URL: https://rpc.d-bis.org
   - Chain ID: 138
   - Currency Symbol: ETH
   - Block Explorer: https://explorer.d-bis.org
5. Click "Save"

Or use the programmatic method:
```javascript
await window.ethereum.request({
  method: 'wallet_addEthereumChain',
  params: [{
    chainId: '0x8a',
    chainName: 'DeFi Oracle Meta Mainnet',
    rpcUrls: ['https://rpc.d-bis.org'],
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    blockExplorerUrls: ['https://explorer.d-bis.org']
  }]
});
```

---

#### Q: How do I add cUSDT or cUSDC tokens?

**A**:
1. Connect to ChainID 138
2. Click "Import tokens"
3. Enter token address:
   - cUSDT: `0x93E66202A11B1772E55407B32B44e5Cd8eda7f22`
   - cUSDC: `0xf22258f57794CC8E06237084b353Ab30fFfa640b`
4. Verify decimals are set to **6** (important!)
5. Click "Add Custom Token"

---

#### Q: Why are decimals not showing correctly?

**A**: MetaMask may have cached incorrect metadata. Fix:
1. Remove the token from MetaMask
2. Re-add the token
3. **Manually set decimals to 6** for cUSDT/cUSDC
4. Or import the updated token list

See: [Fix cUSDT/cUSDC Decimals Guide](./FIX_CUSDT_CUSDC_DECIMALS.md)

---

#### Q: Can I use MetaMask Swaps on ChainID 138?

**A**: Not yet. MetaMask Swaps doesn't currently support ChainID 138. Use DEX UIs that support ChainID 138 instead.

---

#### Q: Can I bridge to ChainID 138?

**A**: Not yet via MetaMask Bridge. Use third-party bridges that support ChainID 138.

---

#### Q: Where can I buy tokens on ChainID 138?

**A**: On-ramp integration is in progress. Currently, you can:
1. Bridge tokens from other chains
2. Use DEX to swap tokens
3. Wait for on-ramp integration

---

#### Q: What tokens are available on ChainID 138?

**A**: 
- **cUSDT** (Compliant Tether USD) - 6 decimals
- **cUSDC** (Compliant USD Coin) - 6 decimals
- **WETH** (Wrapped Ether) - 18 decimals
- **WETH10** (Wrapped Ether v10) - 18 decimals
- **LINK** (Chainlink Token) - 18 decimals

---

#### Q: How do I check my token balance?

**A**:
1. Connect to ChainID 138 in MetaMask
2. Tokens should appear automatically if added
3. Or click "Import tokens" to add manually
4. Check balance in MetaMask wallet

---

#### Q: Transactions are failing. What should I do?

**A**:
1. Check you're on ChainID 138
2. Check you have enough ETH for gas
3. Check token balance is sufficient
4. Try increasing gas limit
5. Check transaction on explorer: https://explorer.d-bis.org

---

#### Q: Where can I see my transaction history?

**A**: 
1. Check MetaMask transaction history
2. Or visit explorer: https://explorer.d-bis.org
3. Enter your address in the search bar
4. View all transactions

---

## Troubleshooting Guide

### Issue: Cannot connect to network

**Solutions**:
1. Verify RPC URL is correct: `https://rpc.d-bis.org`
2. Check internet connection
3. Try secondary RPC: `https://rpc2.d-bis.org`
4. Clear MetaMask cache
5. Restart MetaMask

---

### Issue: Token balance shows as 0

**Solutions**:
1. Verify you're on ChainID 138
2. Check token address is correct
3. Verify token was added correctly
4. Check transaction history
5. Refresh MetaMask

---

### Issue: Transaction stuck/pending

**Solutions**:
1. Check network status
2. Try increasing gas price
3. Cancel and resubmit transaction
4. Check explorer for transaction status
5. Contact support if persists

---

### Issue: Decimals not showing

**Solutions**:
1. Remove token from MetaMask
2. Re-add token with decimals set to 6 (for cUSDT/cUSDC)
3. Or import updated token list
4. Clear MetaMask cache

---

## Support Process

### Tier 1: Self-Service

**Resources**:
- FAQ document
- Troubleshooting guide
- Video tutorials
- Documentation site

**Goal**: Users resolve issues independently

---

### Tier 2: Community Support

**Channels**:
- Discord #support
- GitHub Discussions
- Telegram group

**Goal**: Community helps users

---

### Tier 3: Direct Support

**Channels**:
- Support email
- Direct message (for critical issues)
- Scheduled calls (for complex issues)

**Goal**: Direct assistance for complex issues

---

## Support Metrics

### Track

- Number of support requests
- Response time
- Resolution time
- User satisfaction
- Common issues

### Goals

- Response time: < 24 hours
- Resolution time: < 48 hours
- User satisfaction: > 80%
- Self-service resolution: > 60%

---

## Support Team

### Roles

1. **Community Moderators**:
   - Monitor support channels
   - Answer common questions
   - Escalate complex issues

2. **Technical Support**:
   - Handle technical issues
   - Debug problems
   - Provide solutions

3. **Documentation Team**:
   - Maintain documentation
   - Create guides
   - Update FAQs

---

## Training Materials

### For Support Team

1. **Network Overview**:
   - ChainID 138 basics
   - Network features
   - Token information

2. **MetaMask Integration**:
   - How integration works
   - Common issues
   - Solutions

3. **Troubleshooting**:
   - Common problems
   - Solutions
   - Escalation process

---

## Feedback Collection

### Methods

1. **User Surveys**:
   - Post-integration surveys
   - Satisfaction surveys
   - Feature request surveys

2. **Feedback Forms**:
   - In-app feedback
   - Website feedback form
   - Email feedback

3. **Community Feedback**:
   - GitHub Discussions
   - Discord feedback channel
   - Telegram group

---

## Documentation Updates

### Regular Updates

- Update FAQs based on common questions
- Update troubleshooting guide
- Update user guides
- Update developer docs

### Version Control

- Track documentation versions
- Maintain changelog
- Archive old versions

---

## Success Metrics

### Track

- Support request volume
- Resolution rate
- User satisfaction
- Documentation usage
- Community engagement

### Goals

- Reduce support requests over time
- Increase self-service resolution
- Improve user satisfaction
- Grow community engagement

---

**Last Updated**: 2026-01-26
