import React from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';
import ItemBox from './ItemBox';
import ItemActions from './ItemActions';

import { publicAssetsUrl } from '../utils/api';
import { Item, ItemStatus } from '../interfaces';
import { statusTagClassName } from './ItemDetails';

interface Props {
  store: ItemStore;
}

function ItemList(props: Props) {
  const { store } = props;

  function onItemClick(item: Item) {
    store.focusItem(item);
    store.showItemDetails(item);
  }

  // const itemBoxes = store.filteredItems.map((i) => (
  //   <ItemBox key={`item-${i.id}`} item={i} store={store} />
  // ));

  const itemBoxes = store.filteredItems.map((item, index) => {
    const thumbUrl = item.image?.url ?? '';
    return (
      <div className="item" key={index} style={{ position: 'relative' }}>
        <figure className="image is-2by3" onClick={() => onItemClick(item)}>
          <img src={publicAssetsUrl(thumbUrl)} alt="" />
        </figure>

        {item.status !== ItemStatus.Todo && (
          <span
            className={`status-tag tag is-small ${statusTagClassName(
              item.status
            )}`}
            data-balloon-pos="down"
          >
            {item.human_status}
          </span>
        )}
      </div>
    );
  });

  return (
    <div className="items-grid">{itemBoxes}</div>

    // <div className="items-list">
    //   {itemBoxes}
    //   <ItemActions store={store} />
    // </div>
  );
}

export default observer(ItemList);
