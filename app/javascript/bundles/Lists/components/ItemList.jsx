import React, { Component } from 'react';
import ItemBox from './ItemBox'

const ItemList = ({items, onTagClick}) => {
  const itemBoxes = items.map((i) => (
    <ItemBox key={i.id} item={i} onTagClick={onTagClick} />
  ))

  return (
    <div className="items-list">
      {itemBoxes}
    </div>
  )
}

export default ItemList