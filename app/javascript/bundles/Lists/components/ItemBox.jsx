import React, { Component } from 'react';

const ItemBox = ({ item, onTagClick }) => {
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
            <div className="subtitle is-4"><a href={`/items/${item.id}`}>{item.name}</a></div>
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
              <div key={`item-tag-${tag}`} className="level-item is-hidden-touch item-tag" onClick={() => onTagClick(tag)}>
                <span className="tag is-rounded is-light is-small">
                  {tag}
                </span>
              </div>
            )
          })}
        </div>

        <div className="level-right is-mobile item-actions is-hidden">
          <div className="level-item is-hidden-mobile">
            <a target="blank" href="https://thepiratebay.org/search/The%20Last%20Guardian">
              <span className="icon is-medium" data-balloon="Search the Bay"><i className="fa fa-magnet fa-lg "></i></span>
            </a>
          </div>

          <div className="level-item is-hidden-mobile">
            <a target="blank" href="https://www.google.ch/search?q=The%20Last%20Guardian">
              <span className="icon is-medium" data-balloon="Search Google"><i className="fa fa-google fa-lg "></i></span>
            </a>
          </div>

          <div className="level-item is-hidden-mobile">
            <a target="blank" href="https://www.youtube.com/results?search_query=The%20Last%20Guardian">
              <span className="icon is-medium" data-balloon="Search YouTube"><i className="fa fa-youtube-play fa-lg "></i></span>
            </a>
          </div>

          <div className="level-item is-hidden-mobile">
            <a target="blank" href="https://www.netflix.com/search?q=The%20Last%20Guardian">
              <span className="icon is-medium" data-balloon="Search Netflix"><i className="fa fa-tv fa-lg "></i></span>
            </a>
          </div>

          <div className="level-item">
            <a rel="nofollow" data-method="delete" href={`/items/${item.id}`}>
              <span className="icon is-medium" data-balloon="Archive"><i className="fa fa-archive fa-lg "></i></span>
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ItemBox