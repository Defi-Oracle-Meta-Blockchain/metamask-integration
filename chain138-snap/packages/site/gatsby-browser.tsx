import type { GatsbyBrowser } from 'gatsby';
import { StrictMode } from 'react';

import { App } from './src/App';
import { Root } from './src/Root';

/**
 *
 * @param options0
 * @param options0.element
 */
export const wrapRootElement: GatsbyBrowser['wrapRootElement'] = ({
  element,
}) => (
  <StrictMode>
    <Root>{element}</Root>
  </StrictMode>
);

/**
 *
 * @param options0
 * @param options0.element
 */
export const wrapPageElement: GatsbyBrowser['wrapPageElement'] = ({
  element,
}) => <App>{element}</App>;
