import React from 'react';
import { observer } from 'mobx-react';
import * as Mousetrap from 'mousetrap';

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

      this.props.store.hideDetailsModal();
      this.searchField.focus();
      this.searchField.select();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  onKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    const { store } = this.props;

    switch (e.keyCode) {
      case 9: // Tab to autoComplete or focus first filtered item
        e.preventDefault();
        if (store.canAutoComplete) {
          store.autoComplete();
        } else {
          store.focusNextItem();
          this.searchField.blur();
        }

        return false;
      case 39: // Right arrow
        if (store.canAutoComplete) {
          e.preventDefault();
          store.autoComplete();
          return false;
        }

        return true;
      case 69: // "e" key
        if (e.ctrlKey && store.canAutoComplete) {
          e.preventDefault();
          store.autoComplete();
          return false;
        }

        return true;
      case 13: // ENTER
        this.onSubmit(e);

        return false;
      default:
        return true;
    }
  };

  onChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    this.props.store.filter(e.target.value);
  };

  onSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    this.props.store.scrape();
  };

  get searchField(): HTMLInputElement {
    const currentField = this.inputField.current;
    if (!currentField) {
      throw new Error('OmniBar not ready');
    }

    return currentField;
  }

  onAutocompleteButtonClick = () => {
    this.props.store.autoComplete();
    this.inputField.current!.focus();
  };

  render() {
    const { store } = this.props;

    return (
      <div className="omni-bar" style={{ position: 'relative' }}>
        <input
          style={{ zIndex: 5 }}
          ref={this.inputField}
          value={store.query}
          onChange={this.onChange}
          onKeyDown={this.onKeyDown}
          placeholder="Search"
          autoComplete="off"
          type="text"
        />

        <input
          style={{ zIndex: 1, color: 'rgb(109, 109, 109)' }}
          value={store.autoCompleteSuggestion}
          autoComplete="off"
          autoCorrect="off"
          spellCheck={false}
          type="text"
          disabled
        />

        {store.canAutoComplete && (
          <button
            className="button is-small autocomplete-button is-hidden-desktop"
            style={{ marginLeft: 'auto', zIndex: 5 }}
            onClick={this.onAutocompleteButtonClick}
          >
            <span className="icon is-medium">
              <i className="fa fa-long-arrow-alt-right fa-lg" />
            </span>
          </button>
        )}
      </div>
    );
  }
}

export default OmniBar;
