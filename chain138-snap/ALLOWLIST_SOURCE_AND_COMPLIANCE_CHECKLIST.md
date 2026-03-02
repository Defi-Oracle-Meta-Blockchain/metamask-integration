# Allowlist: source and compliance checklist

Before submitting the Chain 138 Snap for MetaMask allowlisting, confirm:

## Source code

- [ ] Snap source code is **publicly available** (e.g. public Git repo). Repo: **https://github.com/bis-innovations/chain138-snap**

## Compliance

- [ ] The Snap does **not** impair MetaMask’s compliance with laws or regulations (no illicit use of data, keys, or network access).
- [ ] No key-management APIs are used (this Snap does not use `snap_getBip32Entropy`, `snap_getBip44Entropy`, `snap_manageAccounts`, etc.), so **no third-party audit** is required.

## Already done in this repo

- [x] Package name set to `chain138-snap` (no conflict with existing npm `snap`).
- [x] Repository/homepage/bugs set to **https://github.com/bis-innovations/chain138-snap**.
- [x] No `console` logs, to-do comments, or unused permissions in Snap code.
- [x] Security: CI runs MetaMask Security Code Scanner (`.github/workflows/security-code-scanner.yml`). Optionally run [Snapper](https://docs.metamask.io/snaps/how-to/get-allowlisted/) locally before submission.

**Submitted** to the MetaMask Snaps Directory; pending review. For future versions, use the [MetaMask Snaps Directory Information Update form](https://docs.metamask.io/snaps/how-to/get-allowlisted/#5-update-your-snap).
