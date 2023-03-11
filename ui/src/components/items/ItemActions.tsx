import React from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../../stores/ItemStore';

interface Props {
  store: ItemStore;
}

function ItemActions(props: Props) {
  const { store } = props;

  const moreItemsPrompt =
    store.moreItemsToShow === 1
      ? 'Show 1 more item'
      : `Show ${store.moreItemsToShow} more items`;

  return (
    <div
      style={{ display: 'flex', justifyContent: 'center' }}
      className="item-actions"
    >
      {store.hasMoreFilteredItems && (
        <button
          className="button is-rounded is-small"
          onClick={store.showAllItems}
        >
          <span className="icon">
            <i className="fa fa-caret-down" />
          </span>

          <span>{moreItemsPrompt}</span>
        </button>
      )}
    </div>
  );
}

export default observer(ItemActions);
