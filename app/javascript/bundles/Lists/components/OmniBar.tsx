import React from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';

interface Props {
  store: ItemStore;
}

@observer
class OmniBar extends React.Component<Props> {
  render() {
    const { store } = this.props;

    return (
      <form onSubmit={store.onOmniSubmit}>
        <div className="new-item has-bottom-padding omni-bar">
          <p className="control">
            <input
              value={store.query}
              onChange={store.onOmniInput}
              className="input filter is-expanded is-medium"
              id="omni-bar"
              placeholder={'Search'}
              autoComplete="off"
              type="text"
            />
          </p>
        </div>
      </form>
    );
  }
}

export default OmniBar;
