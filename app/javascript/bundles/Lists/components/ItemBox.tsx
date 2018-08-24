import React, { Fragment } from 'react';
import { Item } from '..';
import ItemRating from './ItemRating';

const ArchiveActions = ({
  onArchiveClick
}: {
  onArchiveClick(e: any): void;
}) => (
  <div className="level-item">
    <a target="blank" href="#" onClick={onArchiveClick}>
      <span className="icon is-medium" data-balloon="Archive">
        <i className="fa fa-archive fa-lg" />
      </span>
    </a>
  </div>
);

const RestoreActions = ({
  onRestoreClick,
  onDeleteClick
}: {
  onRestoreClick(e: any): void;
  onDeleteClick(e: any): void;
}) => (
  <Fragment>
    <div className="level-item">
      <a target="blank" href="#" onClick={onRestoreClick}>
        <span className="icon is-medium" data-balloon="Restore">
          <i className="fa fa-recycle fa-lg" />
        </span>
      </a>
    </div>
    <div className="level-item">
      <a target="blank" href="#" onClick={onDeleteClick}>
        <span className="icon is-medium" data-balloon="Delete for good">
          <i className="fa fa-trash fa-lg" />
        </span>
      </a>
    </div>
  </Fragment>
);

interface Props {
  item: Item;
  onTagFilter(tag: string, options: object): void;
  onArchive(item: Item): void;
  onRestore(item: Item): void;
  onDelete(item: Item): void;
  onToggle(item: Item): void;
  onUpdateRating(item: Item, rating: number): void;
}

const ItemBox = ({
  item,
  onTagFilter,
  onArchive,
  onRestore,
  onDelete,
  onToggle,
  onUpdateRating
}: Props) => {
  const thumbUrl = item!.image!.thumb.url;

  const pirateSearchUrl = encodeURI(
    `https://thepiratebay.org/search/${item.name}`
  );
  const youtubeSearchUrl = encodeURI(
    `https://www.youtube.com/results?search_query=${item.name} ${item.year}`
  );
  const googleSearchUrl = encodeURI(
    `https://www.google.ch/search?q=${item.name} ${item.year}`
  );
  const netflixSearchUrl = encodeURI(
    `https://www.netflix.com/search?q=${item.name}`
  );

  const onArchiveClick = (e: any) => {
    e.preventDefault();
    onArchive(item);
  };

  const onRestoreClick = (e: any) => {
    e.preventDefault();
    onRestore(item);
  };

  const onDeleteClick = (e: any) => {
    e.preventDefault();
    onDelete(item);
  };

  const onStatusToggleClick = () => {
    onToggle(item);
  };

  const onTagClick = (e: any, tag: string) => {
    const options = e.metaKey ? { append: true } : {};
    onTagFilter(tag, options);
  };

  const itemActions = item.deleted ? (
    <RestoreActions
      onRestoreClick={onRestoreClick}
      onDeleteClick={onDeleteClick}
    />
  ) : (
    <ArchiveActions onArchiveClick={onArchiveClick} />
  );

  return (
    <div className="box item-box">
      <div
        className={`status-bar is-${item.status} has-pointer show-on-hover ${item.status === 'todo' ? 'hidden' : ''}`}
        data-balloon="Toggle Status"
        onClick={onStatusToggleClick}
      />

      <div className="level is-mobile">
        <div className="level-left is-mobile">
          <div className="level-item">
            <figure className="image is-64x64">
              <img src={thumbUrl} alt={item.name} />
            </figure>
          </div>

          <div
            className="level-item title-item"
            data-balloon={item.description}
            data-balloon-pos="right"
            data-balloon-length="xlarge"
          >
            <div className="subtitle is-5">
              <a href={`/items/${item.id}`}>{item.name}</a>
            </div>
          </div>

          {item.year && (
            <div
              className="level-item has-pointer"
              onClick={(e) => onTagClick(e, `y[${item.year}]`)}
              data-balloon={`Show ${item.year} items`}
            >
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

          {item.tags.map((tag) => (
            <div
              key={`item-tag-${tag}`}
              className="level-item is-hidden-touch has-pointer"
              onClick={(e) => onTagClick(e, `t[${tag}]`)}
              data-balloon={`Show ${tag} items`}
            >
              <span className="tag is-rounded is-light is-small">{tag}</span>
            </div>
          ))}

          <ItemRating item={item} onUpdateRating={onUpdateRating} />
        </div>

        <div className="level-right is-mobile item-actions hidden">
          <div className="level-item is-hidden-mobile">
            <a target="blank" href={pirateSearchUrl}>
              <span className="icon is-medium" data-balloon="Search the Bay">
                <i className="fa fa-magnet fa-lg" />
              </span>
            </a>
          </div>

          <div className="level-item is-hidden-mobile">
            <a target="blank" href={googleSearchUrl}>
              <span className="icon is-medium" data-balloon="Search Google">
                <i className="fa fa-google fa-lg" />
              </span>
            </a>
          </div>

          <div className="level-item is-hidden-mobile">
            <a target="blank" href={youtubeSearchUrl}>
              <span className="icon is-medium" data-balloon="Search YouTube">
                <i className="fa fa-youtube-play fa-lg" />
              </span>
            </a>
          </div>

          <div className="level-item is-hidden-mobile">
            <a target="blank" href={netflixSearchUrl}>
              <span className="icon is-medium" data-balloon="Search Netflix">
                <i className="fa fa-tv fa-lg" />
              </span>
            </a>
          </div>

          {itemActions}
        </div>
      </div>
    </div>
  );
};

export default ItemBox;
