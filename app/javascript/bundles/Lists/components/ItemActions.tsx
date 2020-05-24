import React from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';

interface Props {
  store: ItemStore;
}

@observer
class ItemActions extends React.Component<Props> {
  render() {
    const { store } = this.props;

    const moreItemsPrompt =
      store.moreItemsToShow === 1
        ? 'Show 1 more item'
        : `Show ${store.moreItemsToShow} more items`;

    return (
      <div style={{ display: 'flex', justifyContent: 'center' }}>
        {store.query && (
          <a
            className="button is-rounded is-small"
            onClick={store.showNewItemDetails}
            style={{ marginRight: '1em' }}
          >
            <span className="icon">
              <i className="fa fa-plus" />
            </span>

            <span>Create item from search</span>
          </a>
        )}

        {store.hasMoreFilteredItems && (
          <a
            className="button is-rounded is-small"
            onClick={store.showAllItems}
          >
            <span className="icon">
              <i className="fa fa-caret-down" />
            </span>

            <span>{moreItemsPrompt}</span>
          </a>
        )}
      </div>
    );
  }
}

export default ItemActions;
