import React, { Component } from 'react';
import ItemBox from './ItemBox'

const ItemList = ({ items, onTagClick, onItemArchive, onItemRestore, onItemDelete, onItemToggle }) => {
  const itemBoxes = items.map((i) => (
    <ItemBox
      key={`item-${i.id}`}
      item={i}
      onTagClick={onTagClick}
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