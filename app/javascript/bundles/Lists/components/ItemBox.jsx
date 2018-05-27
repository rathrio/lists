import React, { Fragment } from 'react';

const StatusTags = ({ item }) => {
  let tagColor

  switch (item.status) {
    case 'doing':
      tagColor = 'warning'
      break
    case 'done':
      tagColor = 'success'
      break
    default:
      return ""
  }

  return (
    <div className="level-item has-pointer">
      <span className={`tag is-rounded is-small is-${tagColor}`}>
        {item.human_status}
      </span>
    </div>
  )
}

const ArchiveActions = ({ onArchiveClick }) => (
  <div className="level-item">
    <a target="blank" href="#" onClick={onArchiveClick}>
      <span className="icon is-medium" data-balloon="Archive"><i className="fa fa-archive fa-lg"></i></span>
    </a>
  </div>
)

const RestoreActions = ({ onRestoreClick, onDeleteClick }) => (
  <Fragment>
    <div className="level-item">
      <a target="blank" href="#" onClick={onRestoreClick}>
        <span className="icon is-medium" data-balloon="Restore"><i className="fa fa-recycle fa-lg"></i></span>
      </a>
    </div>
    <div className="level-item">
      <a target="blank" href="#" onClick={onDeleteClick}>
        <span className="icon is-medium" data-balloon="Delete for good"><i className="fa fa-trash fa-lg"></i></span>
      </a>
    </div>
  </Fragment>
)

const ItemBox = ({ item, onTagFilter, onArchive, onRestore, onDelete, onToggle }) => {
  const thumbUrl = item.image.thumb.url

  const pirateSearchUrl = encodeURI(`https://thepiratebay.org/search/${item.name}`)
  const youtubeSearchUrl = encodeURI(`https://www.youtube.com/results?search_query=${item.name}`)
  const googleSearchUrl = encodeURI(`https://www.google.ch/search?q=${item.name}`)
  const netflixSearchUrl = encodeURI(`https://www.netflix.com/search?q=${item.name}`)

  const onArchiveClick = (e) => {
    e.preventDefault()
    onArchive(item)
  }

  const onRestoreClick = (e) => {
    e.preventDefault()
    onRestore(item)
  }

  const onDeleteClick = (e) => {
    e.preventDefault()
    onDelete(item)
  }

  const onStatusToggleClick = () => {
    onToggle(item)
  }

  const onTagClick = (e, tag) => {
    const options = (e.metaKey) ? { append: true } : {}
    onTagFilter(tag, options)
  }

  const itemActions = (item.deleted) ?
    <RestoreActions onRestoreClick={onRestoreClick} onDeleteClick={onDeleteClick} /> :
    <ArchiveActions onArchiveClick={onArchiveClick} />

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
            <div className="subtitle is-5"><a href={`/items/${item.id}`}>{item.name}</a></div>
          </div>

          {item.status !== 'todo' && <StatusTags item={item} />}

          {item.year && (
            <div className="level-item has-pointer" onClick={e => onTagClick(e, `y:[${item.year}]`)} data-balloon={`Show ${item.year} items`}>
              <span className="tag is-rounded is-light is-small">
                {item.year}
              </span>
            </div>
          )}

          {item.deleted && (
            <div className="level-item has-pointer">
              <span className="tag is-rounded is-light is-small">
                {item.list}
              </span>
            </div>
          )}

          {item.tags.map((tag) => {
            return (
              <div key={`item-tag-${tag}`} className="level-item is-hidden-touch has-pointer" onClick={e => onTagClick(e, `t:[${tag}]`)} data-balloon={`Show ${tag} items`}>
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

          {itemActions}

          <div className="level-item has-pointer" onClick={onStatusToggleClick}>
            <span className="icon is-medium" data-balloon="Toggle Status"><i className={`fa fa-check fa-lg item-status-toggle is-${item.status}`}></i></span>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ItemBox
