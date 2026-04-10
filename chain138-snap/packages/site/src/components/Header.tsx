import styled, { useTheme } from 'styled-components';

import { HeaderButtons } from './Buttons';
import { SnapLogo } from './SnapLogo';
import { Toggle } from './Toggle';
import { getThemePreference } from '../utils';

const HeaderWrapper = styled.header`
  color: #fff;
  background: linear-gradient(
    135deg,
    ${(props) => props.theme.colors.primary?.default} 0%,
    ${(props) => props.theme.colors.primary?.dark} 100%
  );
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 1000;
  border-bottom: 1px solid ${(props) => props.theme.colors.border?.default};
`;

const HeaderInner = styled.div`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  gap: 0.85rem;
  padding: 0.7rem 1.25rem;
  max-width: 1320px;
  margin: 0 auto;

  ${({ theme }) => theme.mediaQueries.small} {
    padding: 0.55rem 0.9rem;
    flex-wrap: wrap;
    align-items: stretch;
  }
`;

const Title = styled.p`
  font-size: ${(props) => props.theme.fontSizes.title};
  font-weight: bold;
  margin: 0;
  line-height: 1.05;

  ${({ theme }) => theme.mediaQueries.small} {
    font-size: 1.1rem;
  }
`;

const LogoWrapper = styled.div`
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
  color: inherit;
  padding: 0.25rem 0.4rem;
  border-radius: 11px;
  transition:
    background 0.2s,
    transform 0.2s;

  &:hover,
  &:focus-visible {
    background: rgba(255, 255, 255, 0.12);
    transform: translateY(-1px);
    outline: none;
  }

  ${({ theme }) => theme.mediaQueries.small} {
    gap: 0.45rem;
    padding: 0.22rem 0.35rem;
  }
`;

const RightContainer = styled.div`
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
  justify-content: flex-end;

  ${({ theme }) => theme.mediaQueries.small} {
    width: 100%;
    justify-content: space-between;
  }
`;

const Brand = styled.div`
  display: flex;
  flex-direction: column;
  gap: 0.08rem;

  ${({ theme }) => theme.mediaQueries.small} {
    gap: 0.08rem;
  }
`;

const BrandSubtitle = styled.span`
  font-size: 0.7rem;
  font-weight: normal;
  opacity: 0.9;
  line-height: 1.1;

  ${({ theme }) => theme.mediaQueries.small} {
    font-size: 0.62rem;
  }
`;

/**
 * Render the companion site header.
 *
 * @param options0 - Header props.
 * @param options0.handleToggleClick - Toggles the site theme.
 * @returns The header element.
 */
export const Header = ({
  handleToggleClick,
}: {
  /** Toggles the site theme. */
  handleToggleClick: () => void;
}) => {
  const theme = useTheme();

  return (
    <HeaderWrapper>
      <HeaderInner>
        <LogoWrapper as="a" href="/home" aria-label="Go to explorer home">
          <SnapLogo color={theme.colors.icon?.default} size={30} />
          <Brand>
            <Title>Chain 138 Snap</Title>
            <BrandSubtitle>Chain 138 Explorer by DBIS</BrandSubtitle>
          </Brand>
        </LogoWrapper>
        <RightContainer>
          <Toggle
            onToggle={handleToggleClick}
            defaultChecked={getThemePreference()}
          />
          <HeaderButtons />
        </RightContainer>
      </HeaderInner>
    </HeaderWrapper>
  );
};
