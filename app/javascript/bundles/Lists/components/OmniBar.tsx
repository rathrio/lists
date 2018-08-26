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

      this.searchField.focus();
      this.searchField.select();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  onKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.keyCode !== 9) {
      return true;
    }

    e.preventDefault();
    this.props.store.focusNextItem();

    this.searchField.blur();
    return false;
  }

  onChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    this.props.store.filter(e.target.value);
  }

  onSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    this.props.store.scrape();
  }

  get searchField(): HTMLInputElement {
    const currentField = this.inputField.current;
    if (!currentField) {
      throw new Error('OmniBar not ready');
    }

    return currentField;
  }

  render() {
    const { store } = this.props;

    return (
      <form onSubmit={this.onSubmit}>
        <div className="new-item has-bottom-padding omni-bar">
          <p className="control">
            <input
              ref={this.inputField}
              value={store.query}
              onChange={this.onChange}
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
