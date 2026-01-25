import React, { useState } from 'react';

interface Props {
  title: string;
  defaultExpanded?: boolean;
  children: React.ReactNode;
}

const CollapsibleSection: React.FC<Props> = ({
  title,
  defaultExpanded = false,
  children,
}) => {
  const [isExpanded, setIsExpanded] = useState(defaultExpanded);

  return (
    <div
      className="mt-5"
      style={{
        backgroundColor: 'var(--bulma-scheme-main-bis)',
        borderRadius: '6px',
        overflow: 'hidden',
      }}
    >
      <div
        onClick={() => setIsExpanded(!isExpanded)}
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '0.75rem 1rem',
          cursor: 'pointer',
          userSelect: 'none',
        }}
      >
        <span style={{ fontWeight: 500 }}>{title}</span>
        <span className="icon is-small">
          <i className={`fas fa-chevron-${isExpanded ? 'up' : 'down'}`} />
        </span>
      </div>
      {isExpanded && (
        <div
          className="collapsible-content"
          style={{ padding: '0 1rem 1rem 1rem' }}
        >
          {children}
        </div>
      )}
    </div>
  );
};

export default CollapsibleSection;
