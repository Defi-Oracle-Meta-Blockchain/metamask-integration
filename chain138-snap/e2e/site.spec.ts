import { test, expect } from '@playwright/test';

test.describe('Chain 138 Snap companion site', () => {
  test('loads and shows Connect, Install, or Reconnect', async ({ page }) => {
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    // Connect and Reconnect are buttons; Install MetaMask Flask is a link
    const connectOrReconnect = page.getByRole('button', { name: /Connect|Reconnect/i });
    const installLink = page.getByRole('link', { name: /Install MetaMask Flask/i });
    await expect(connectOrReconnect.or(installLink).first()).toBeVisible({ timeout: 30_000 });
  });

  test('page has Snap-related content', async ({ page }) => {
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    const body = page.locator('body');
    await expect(body).toContainText(/Connect|Chain 138|Get started|Snap|Install|Reconnect/i, { timeout: 30_000 });
  });
});
