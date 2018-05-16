import React, { Component } from 'react';

const ItemBox = ({item, onTagClick}) => {
  const thumbUrl = item.image.thumb.url

  return (
    <div className="box item-box">
      <div className="level is-mobile">
        <div className="level-left is-mobile">
          <div className="level-item">
            <figure className="image is-64x64">
              <img src={thumbUrl} />
            </figure>
          </div>

          <div className="level-item title-item">
            <div className="subtitle is-4"><a href="/items/1484">{item.name}</a></div>
          </div>

          <div className="level-item">
            <span className="tag is-rounded is-light is-small">
              {item.year}
            </span>
          </div>

          <div className="level-item is-hidden-mobile">
            <span className="tag is-rounded is-light is-small">
              {item.list}
            </span>
          </div>

          {item.tags.map((tag) => {
            return(
              <div key={tag} className="level-item is-hidden-touch item-tag" onClick={() => onTagClick(tag)}>
                <span className="tag is-rounded is-light is-small">
                  {tag}
                </span>
              </div>
            )
          })}

        </div>

        <div className="level-right is-mobile item-actions is-hidden">
        </div>
      </div>
    </div>
  )
}

export default ItemBox