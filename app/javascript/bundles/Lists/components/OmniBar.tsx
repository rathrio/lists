import React from 'react';

interface Props {
  query?: string;
  placeholder?: string;
  onInput(e: any): void;
  onSubmit(e: any): void;
}

const OmniBar = ({ query, placeholder, onInput, onSubmit }: Props) => {
  return (
    <form onSubmit={onSubmit}>
      <div className="new-item has-bottom-padding omni-bar">
        <p className="control">
          <input
            value={query}
            onChange={onInput}
            className="input filter is-expanded is-medium"
            id="omni-bar"
            placeholder={placeholder || 'Search'}
            autoComplete="off"
            type="text"
          />
        </p>
      </div>
    </form>
  );
};

export default OmniBar;
