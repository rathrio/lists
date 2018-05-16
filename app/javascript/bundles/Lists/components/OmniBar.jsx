import PropTypes from 'prop-types'
import React from 'react';

const OmniBar = ({query, placeholder, onInput}) => {
  return(
    <div className="new-item has-bottom-padding omni-bar">
      <p className="control has-addons">
        <input value={query} onChange={onInput} className="input filter is-expanded is-medium" placeholder={placeholder} autoComplete="off" type="text" />
      </p>
    </div>
  )
}

OmniBar.propTypes = {
  query: PropTypes.string,
  placeholder: PropTypes.string,
  onInput: PropTypes.func
}

OmniBar.defaultProps = {
  placeholder: 'Search'
}

export default OmniBar