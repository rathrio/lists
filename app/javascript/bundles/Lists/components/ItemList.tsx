import React from 'react';
import ItemBox from './ItemBox';
import { Item } from '..';

interface Props {
  items: Item[];
  onTagFilter(tag: string, options: object): void;
  onItemArchive(item: Item): void;
  onItemRestore(item: Item): void;
  onItemDelete(item: Item): void;
  onItemToggle(item: Item): void;
}

const ItemList = ({
  items,
  onTagFilter,
  onItemArchive,
  onItemRestore,
  onItemDelete,
  onItemToggle
}: Props) => {
  const itemBoxes = items.map((i) => (
    <ItemBox
      key={`item-${i.id}`}
      item={i}
      onTagFilter={onTagFilter}
      onArchive={onItemArchive}
      onRestore={onItemRestore}
      onDelete={onItemDelete}
      onToggle={onItemToggle}
    />
  ));

  return <div className="items-list">{itemBoxes}</div>;
};

export default ItemList;
