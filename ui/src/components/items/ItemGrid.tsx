import { observer } from 'mobx-react';

import { Item, ItemStatus } from '../../interfaces';
import { statusTagClassName } from './ItemDetails';
import ItemActions from './ItemActions';
import RootStore from '../../stores/RootStore';
import CoverBox from './CoverBox';
import { publicAssetsUrl } from '../../utils/api';
import { ITEMS_TO_SHOW } from '../../stores/ItemStore';

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
    <CoverBox
      coverUrl={publicAssetsUrl(thumbUrl)}
      isCoverMissing={!thumbUrl}
      title={item.name}
      coverAspectRatio={coverAspectRatio}
      isFocused={itemStore.isFocused(item)}
      onClick={() => onItemClick(item)}
      tag={item.status !== ItemStatus.Todo ? item.human_status : undefined}
      tagClass={statusTagClassName(item.status)}
    >
      <p>{item.year}</p>
      <ItemRating item={item} />
    </CoverBox>
  );
});

const PlaceholderGrid = observer((props: Props) => {
  const { store } = props;
  const coverAspectRatio = store.listStore.activeList!.cover_aspect_ratio;

  const placeholders = [...Array(ITEMS_TO_SHOW)].map((_, i) => (
    <CoverBox
      coverUrl={''}
      isCoverMissing={true}
      title={''}
      coverAspectRatio={coverAspectRatio}
      disablePointer={true}
      onClick={() => {}}
      className={`i${i % 9}`}
    >
      <p>&nbsp;</p>
    </CoverBox>
  ));

  return <div className="items-grid placeholder-grid">{placeholders}</div>;
});

function ItemGrid(props: Props) {
  const { store } = props;
  if (store.itemStore.isLoading) {
    return <PlaceholderGrid {...props} />;
  }

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
