import React from 'react';

const Spinner = ({size}) => (
  <div className="columns">
    <div className="column is-1 is-offset-5">
      <span className="icon is-large">
        <i className="fa fa-spinner fa-pulse fa-3x"></i>
      </span>
    </div>
  </div>
)

export default Spinner