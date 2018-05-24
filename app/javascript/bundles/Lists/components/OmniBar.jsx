import PropTypes from 'prop-types'
import React from 'react';

const OmniBar = ({ query, placeholder, onInput, onSubmit }) => {
  const onKeyPress = (e) => {
    if (e.key === 'Enter') {
      onSubmit(e)
    }

    return true
  }

  return(
    <div className="new-item has-bottom-padding omni-bar">
      <p className="control">
        <input value={query} onChange={onInput} onKeyPress={onKeyPress} className="input filter is-expanded is-medium" placeholder={placeholder} autoComplete="off" type="text" />
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