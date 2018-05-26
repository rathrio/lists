import React, { Component } from 'react';

const ItemBox = ({ item, onTagClick, onArchive }) => {
  const thumbUrl = item.image.thumb.url

  const onArchiveClick = (e) => {
    e.preventDefault()
    onArchive(item)
  }

  const pirateSearchUrl = encodeURI(`https://thepiratebay.org/search/${item.name}`)
  const youtubeSearchUrl = encodeURI(`https://www.youtube.com/results?search_query=${item.name}`)
  const googleSearchUrl = encodeURI(`https://www.google.ch/search?q=${item.name}`)
  const netflixSearchUrl = encodeURI(`https://www.netflix.com/search?q=${item.name}`)

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
            <a target="blank" href={pirateSearchUrl}>
              <span className="icon is-medium" data-balloon="Search the Bay"><i className="fa fa-magnet fa-lg"></i></span>
            </a>
          </div>

          <div className="level-item is-hidden-mobile">
            <a target="blank" href={googleSearchUrl}>
              <span className="icon is-medium" data-balloon="Search Google"><i className="fa fa-google fa-lg"></i></span>
            </a>
          </div>

          <div className="level-item is-hidden-mobile">
            <a target="blank" href={youtubeSearchUrl}>
              <span className="icon is-medium" data-balloon="Search YouTube"><i className="fa fa-youtube-play fa-lg"></i></span>
            </a>
          </div>

          <div className="level-item is-hidden-mobile">
            <a target="blank" href={netflixSearchUrl}>
              <span className="icon is-medium" data-balloon="Search Netflix"><i className="fa fa-tv fa-lg"></i></span>
            </a>
          </div>

          <div className="level-item has-pointer">
            <a target="blank" href="#" onClick={onArchiveClick}>
              <span className="icon is-medium" data-balloon="Archive"><i className="fa fa-archive fa-lg"></i></span>
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ItemBox
