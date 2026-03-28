import styled, { useTheme } from 'styled-components';

import { getBuildVersion } from '../config';
import { MetaMask } from './MetaMask';
import { PoweredBy } from './PoweredBy';
import { ReactComponent as MetaMaskFox } from '../assets/metamask_fox.svg';

const FooterWrapper = styled.footer`
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  padding-top: 2.4rem;
  padding-bottom: 2.4rem;
  border-top: 1px solid ${(props) => props.theme.colors.border?.default};
`;

const VersionSpan = styled.span`
  font-size: ${({ theme }) => theme.fontSizes.small};
  color: ${(props) => props.theme.colors.text?.muted};
`;

const PoweredByButton = styled.a`
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: center;
  padding: 1.2rem;
  border-radius: ${({ theme }) => theme.radii.button};
  box-shadow: ${({ theme }) => theme.shadows.button};
  background-color: ${({ theme }) => theme.colors.background?.alternative};
`;

const PoweredByContainer = styled.div`
  display: flex;
  flex-direction: column;
  margin-left: 1rem;
`;

const LegalColumn = styled.div`
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  min-width: 16rem;
`;

const SectionTitle = styled.div`
  font-size: ${({ theme }) => theme.fontSizes.small};
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: ${({ theme }) => theme.colors.text?.muted};
  margin-bottom: 0.4rem;
`;

const FooterLink = styled.a`
  color: ${({ theme }) => theme.colors.text?.default};
  text-decoration: none;

  &:hover {
    text-decoration: underline;
  }
`;

/**
 * @returns The Snap footer with brand, legal links, and build metadata.
 */
export const Footer = () => {
  const theme = useTheme();
  const buildVersion = getBuildVersion();
  const currentYear = new Date().getFullYear();

  return (
    <FooterWrapper>
      <PoweredByButton href="https://docs.metamask.io/" target="_blank">
        <MetaMaskFox />
        <PoweredByContainer>
          <PoweredBy color={theme.colors.text?.muted} />
          <MetaMask color={theme.colors.text?.default} />
        </PoweredByContainer>
      </PoweredByButton>
      <LegalColumn>
        <SectionTitle>Explorer</SectionTitle>
        <FooterLink href="https://explorer.d-bis.org/docs.html">
          Documentation
        </FooterLink>
        <FooterLink href="https://explorer.d-bis.org/privacy.html">
          Privacy Policy
        </FooterLink>
        <FooterLink href="https://explorer.d-bis.org/terms.html">
          Terms of Service
        </FooterLink>
        <FooterLink href="https://explorer.d-bis.org/acknowledgments.html">
          Acknowledgments
        </FooterLink>
        <FooterLink href="mailto:support@d-bis.org">
          support@d-bis.org
        </FooterLink>
      </LegalColumn>
      <VersionSpan title="Copyright">
        © {currentYear} Solace Bank Group PLC
      </VersionSpan>
      {buildVersion ? (
        <VersionSpan title="Build version">v{buildVersion}</VersionSpan>
      ) : null}
    </FooterWrapper>
  );
};
