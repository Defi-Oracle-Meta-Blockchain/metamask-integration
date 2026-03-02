import type { GatsbyConfig } from 'gatsby';

const config: GatsbyConfig = {
  // When deployed under explorer at /snap/, set pathPrefix so assets load correctly.
  pathPrefix: process.env.GATSBY_PATH_PREFIX || '/',
  // This is required to make use of the React 17+ JSX transform.
  jsxRuntime: 'automatic',

  plugins: [
    'gatsby-plugin-svgr',
    'gatsby-plugin-styled-components',
    {
      resolve: 'gatsby-plugin-manifest',
      options: {
        name: 'Chain 138 Snap',
        icon: 'src/assets/logo.svg',

        theme_color: '#6F4CFF',
        background_color: '#FFFFFF',

        display: 'standalone',
      },
    },
  ],
};

export default config;
