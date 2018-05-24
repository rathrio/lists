import React, { Component } from 'react';
import ItemBox from './ItemBox'

const ItemList = ({ items, onTagClick }) => {
  const itemBoxes = items.map((i) => (
    <ItemBox key={`item-${i.id}`} item={i} onTagClick={onTagClick} />
  ))

  return (
    <div className="items-list">
      {itemBoxes}
    </div>
  )
}

export default ItemList