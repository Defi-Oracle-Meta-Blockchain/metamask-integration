# MetaMask Snaps Directory — Allowlist form fields

Use this when submitting the Chain 138 Snap via the [MetaMask Snaps Directory Information form](https://docs.metamask.io/snaps/how-to/get-allowlisted/#1-submit-your-snap).

## Pre-filled values

| Field                           | Value                                                                                           |
| ------------------------------- | ----------------------------------------------------------------------------------------------- |
| **Snap name**                   | Chain 138 _(must match `proposedName` in snap.manifest.json)_                                   |
| **Snap builder name and URL**   | BIS Innovations — https://github.com/bis-innovations                                            |
| **Snap website URL**            | https://github.com/bis-innovations/chain138-snap#readme _(or your deployed companion site URL)_ |
| **GitHub repository**           | https://github.com/bis-innovations/chain138-snap                                                |
| **npm package**                 | https://www.npmjs.com/package/chain138-snap                                                     |
| **Snap version to allowlist**   | 0.1.2 _(must match package.json and snap.manifest.json)_                                        |
| **Snap auditor / audit report** | Leave blank _(no key-management APIs; audit not required)_                                      |

## Short description (1–2 sentences)

Chain 138 adds DeFi Oracle Meta Mainnet (and ALL Mainnet) support in MetaMask: network params, token list, market data, swap quotes, and bridge routes (CCIP and Trustless). Use with the token-aggregation API for full features.

## Long description

Use line breaks and lists; no HTML. Example:

- **Networks:** Chain 138 (DeFi Oracle Meta Mainnet) and ALL Mainnet (651940); full EIP-3085 params from API.
- **Token list & market data:** Tokens and USD prices via token-aggregation (or optional JSON URLs).
- **Swap quotes:** In-Snap quotes for Chain 138 when quote API is configured.
- **Bridge routes:** CCIP (WETH9/WETH10) and Trustless (Lockbox) routes to Ethereum Mainnet when bridge API is available.

After installing, dApps must pass `apiBaseUrl` (your token-aggregation base URL) when invoking the Snap for market data, swap quote, and bridge routes. See the repo README and INTEGRATORS.md.

## Customer support

- **Escalation contact:** _(confidential; provide email or contact form)_
- **Public support:** GitHub Issues — https://github.com/bis-innovations/chain138-snap/issues  
  _(Add at least one other channel, e.g. docs link or support URL.)_

## Images

Screenshots or promotional images of the Snap (companion site, dialogs, or in-wallet UI). Upload as required by the form.

## Demo video (optional)

Video walkthrough of installing and using the Snap. Helps review and may be used by MetaMask marketing.

---

After submission, the Snap will be reviewed (at least two approvals). Once allowlisted, it will appear in the MetaMask Snaps Directory and users can install it on standard MetaMask (non-Flask).
