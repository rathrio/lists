import React from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';
import ItemBox from './ItemBox';
import ItemActions from './ItemActions';

import { Item } from '../interfaces';

interface Props {
  store: ItemStore;
}

function ItemList(props: Props) {
  const { store } = props;

  function onItemClick(item: Item) {
    store.focusItem(item);
    store.showItemDetails(item);
  }

  const itemBoxes = store.filteredItems.map((i) => (
    <ItemBox key={`item-${i.id}`} item={i} store={store} />
  ));

  return (
    <div className="items-list">
      {itemBoxes}
      <ItemActions store={store} />
    </div>
  );
}

export default observer(ItemList);
