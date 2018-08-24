import React from 'react';
import { observer } from 'mobx-react';
import * as Mousetrap from 'mousetrap'

import ItemStore from '../stores/ItemStore';

interface Props {
  store: ItemStore;
}

@observer
class OmniBar extends React.Component<Props> {
  readonly inputField = React.createRef<HTMLInputElement>();

  constructor(props: Props) {
    super(props);

    Mousetrap.bind('/', (e) => {
      e.preventDefault();

      const currentField = this.inputField.current;
      if (!currentField) {
        return;
      }

      currentField.focus();
      currentField.select();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  onKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.keyCode !== 9) {
      return true;
    }

    e.preventDefault();
    this.props.store.focusNextItem();

    const currentField = this.inputField.current;
    if (!currentField) {
      return false;
    }
    currentField.blur();
    return false;
  }

  render() {
    const { store } = this.props;

    return (
      <form onSubmit={store.onOmniSubmit}>
        <div className="new-item has-bottom-padding omni-bar">
          <p className="control">
            <input
              ref={this.inputField}
              value={store.query}
              onChange={store.onOmniInput}
              onKeyDown={this.onKeyDown}
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
