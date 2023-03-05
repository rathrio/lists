import React from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';

import { publicAssetsUrl } from '../utils/api';
import { Item, ItemStatus } from '../interfaces';
import { statusTagClassName } from './ItemDetails';
import ItemActions from './ItemActions';

interface Props {
  store: ItemStore;
}

function renderStar(currentRating: number, n: number) {
  const starIcon = n <= currentRating ? 'fas fa-star' : 'far fa-star';
  const className = `${starIcon} fa-sm item-rating-star`;

  return (
    <span key={n}>
      <i className={className} />
    </span>
  );
}

const DEFAULT_RATINGS = [1, 2, 3, 4, 5];

function ItemRating(props: { item: Item }) {
  const { item } = props;
  if (!item.rating) {
    return null;
  }

  const stars = DEFAULT_RATINGS.map((r) => renderStar(item.rating!, r));
  return <div className="item-rating">{stars}</div>;
}

function ItemInfo(props: { item: Item }) {
  const { item } = props;
  return (
    <div className="item-info">
      <p>{item.year}</p>
      <ItemRating item={item} />
    </div>
  );
}

function ItemBox(props: { item: Item; store: ItemStore }) {
  const { item, store } = props;

  function onItemClick(item: Item) {
    store.focusItem(item);
    store.showItemDetails(item);
  }

  const thumbUrl = item.image?.url ?? '';
  return (
    <div className="item" style={{ position: 'relative' }}>
      <figure className="image is-2by3 has-pointer" onClick={() => onItemClick(item)}>
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

      <ItemInfo item={item} />
    </div>
  );
}

function ItemGrid(props: Props) {
  const { store } = props;

  const itemBoxes = store.filteredItems.map((item, index) => {
    return <ItemBox item={item} store={store} key={index} />;
  });

  return (
    <>
      <div className="items-grid">{itemBoxes}</div>
      <ItemActions store={store} />
    </>

    // <div className="items-list">
    //   {itemBoxes}
    //   <ItemActions store={store} />
    // </div>
  );
}

export default observer(ItemGrid);
