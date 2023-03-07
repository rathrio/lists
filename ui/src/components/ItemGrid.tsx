import React from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';

import { publicAssetsUrl } from '../utils/api';
import { Item, ItemStatus } from '../interfaces';
import { statusTagClassName } from './ItemDetails';
import ItemActions from './ItemActions';
import RootStore from '../stores/RootStore';

interface Props {
  store: RootStore;
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

const ItemBox = observer((props: { item: Item; store: RootStore }) => {
  const { item, store } = props;
  const itemStore = store.itemStore;

  function onItemClick(item: Item) {
    itemStore.focusItem(item);
    itemStore.showItemDetails(item);
  }

  const thumbUrl = item.image?.url ?? '';
  const coverAspectRatio = store.listStore.activeList!.cover_aspect_ratio;

  return (
    <div
      className={`item ${itemStore.isFocused(item) && 'is-focused'}`}
      style={{ position: 'relative' }}
    >
      <figure
        className={`image is-${coverAspectRatio} has-pointer`}
        onClick={() => onItemClick(item)}
      >
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
});

function ItemGrid(props: Props) {
  const { store } = props;

  const itemBoxes = store.itemStore.filteredItems.map((item, index) => {
    return <ItemBox item={item} store={store} key={index} />;
  });

  return (
    <>
      <div className="items-grid">{itemBoxes}</div>
      <ItemActions store={store.itemStore} />
    </>
  );
}

export default observer(ItemGrid);
