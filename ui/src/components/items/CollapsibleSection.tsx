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
  const contentRef = React.useRef<HTMLDivElement>(null);
  const wrapperRef = React.useRef<HTMLDivElement>(null);

  React.useEffect(() => {
    const wrapper = wrapperRef.current;
    const content = contentRef.current;
    if (!wrapper || !content) return;

    // Use a ResizeObserver to update height if content changes while expanded
    const observer = new ResizeObserver(() => {
      if (isExpanded) {
        wrapper.style.height = `${content.scrollHeight}px`;
      }
    });

    observer.observe(content);

    if (isExpanded) {
      wrapper.style.height = `${content.scrollHeight}px`;
      wrapper.style.opacity = '1';
      wrapper.style.visibility = 'visible';
    } else {
      wrapper.style.height = '0px';
      wrapper.style.opacity = '0';
      wrapper.style.visibility = 'hidden';
    }

    return () => observer.disconnect();
  }, [isExpanded, children]);

  return (
    <div
      className={`mt-5 collapsible-section ${isExpanded ? 'is-expanded' : ''}`}
      style={{
        backgroundColor: 'var(--bulma-scheme-main-bis)',
        borderRadius: '6px',
        overflow: 'hidden',
      }}
    >
      <div
        className="collapsible-trigger"
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
          <i className="fas fa-chevron-down" />
        </span>
      </div>
      <div
        ref={wrapperRef}
        className="collapsible-content-wrapper"
        style={{
          transition:
            'height 0.2s ease, opacity 0.2s ease, visibility 0.2s ease',
        }}
      >
        <div
          ref={contentRef}
          className="collapsible-content"
          style={{ padding: '0 1rem 1rem 1rem' }}
        >
          {children}
        </div>
      </div>
    </div>
  );
};

export default CollapsibleSection;
