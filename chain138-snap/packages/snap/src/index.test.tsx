import { expect } from '@jest/globals';
import type { SnapConfirmationInterface } from '@metamask/snaps-jest';
import { installSnap } from '@metamask/snaps-jest';
import { Box, Text, Bold } from '@metamask/snaps-sdk/jsx';

/**
 *
 */
type SnapsJestExpect = {
  /**
   *
   */
  toRender: (expected: unknown) => void;
  /**
   *
   */
  toRespondWith: (expected: unknown) => void;
  /**
   *
   */
  toRespondWithError: (expected: unknown) => void;
};

describe('onRpcRequest', () => {
  describe('hello', () => {
    it('shows a confirmation dialog', async () => {
      const { request } = await installSnap();

      const origin = 'Jest';
      const response = request({
        method: 'hello',
        origin,
      });

      const ui = (await response.getInterface()) as SnapConfirmationInterface;
      expect(ui.type).toBe('confirmation');
      (expect(ui) as unknown as SnapsJestExpect).toRender(
        <Box>
          <Text>
            Hello, <Bold>{origin}</Bold>!
          </Text>
          <Text>Chain 138 (DeFi Oracle Meta Mainnet) Snap.</Text>
          <Text>
            Use get_networks or get_chain138_config for wallet_addEthereumChain.
          </Text>
        </Box>,
      );

      await ui.ok();

      (expect(await response) as unknown as SnapsJestExpect).toRespondWith(
        true,
      );
    });
  });

  it('throws an error if the requested method does not exist', async () => {
    const { request } = await installSnap();

    const response = await request({
      method: 'foo',
    });

    (expect(response) as unknown as SnapsJestExpect).toRespondWithError({
      code: -32603,
      message: 'Method not found.',
      stack: expect.any(String),
    });
  });
});
