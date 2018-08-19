import React from 'react';
import ItemStore from '../stores/ItemStore';

interface Props {
  store: ItemStore;
}

class ShowMoreItemsButton extends React.Component<Props> {
  render() {
    const { store } = this.props;

    const prompt =
      store.moreItemsToShow === 1
        ? 'Show 1 more item'
        : `Show ${store.moreItemsToShow} more items`;

    if (!store.hasMoreFilteredItems) {
      return '';
    }

    return (
      <div style={{ display: 'flex', justifyContent: 'center' }}>
        <a className="button is-rounded is-small" onClick={store.showAllItems}>
          <span className="icon">
            <i className="fa fa-caret-down" />
          </span>

          <span>{prompt}</span>
        </a>
      </div>
    );
  }
}

export default ShowMoreItemsButton;
