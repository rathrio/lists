import React from 'react';
import ItemBox from './ItemBox'

const ItemList = ({ items, onTagFilter, onItemArchive, onItemRestore, onItemDelete, onItemToggle }) => {
  const itemBoxes = items.map((i) => (
    <ItemBox
      key={`item-${i.id}`}
      item={i}
      onTagFilter={onTagFilter}
      onArchive={onItemArchive}
      onRestore={onItemRestore}
      onDelete={onItemDelete}
      onToggle={onItemToggle} />
  ))

  return (
    <div className="items-list">
      {itemBoxes}
    </div>
  )
}

export default ItemList