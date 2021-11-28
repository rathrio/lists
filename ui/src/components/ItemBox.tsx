import React, { Fragment } from 'react';
import { observer } from 'mobx-react';
import scrollIntoView from 'scroll-into-view-if-needed';
import _ from 'lodash';

import { Item, Tag } from '../interfaces';
import ItemRating, { RATING_NAMES } from './ItemRating';
import * as urls from '../utils/externalItemUrls';
import ItemStore from '../stores/ItemStore';
import { publicAssetsUrl } from '../utils/api';

const RestoreActions = ({
  onRestoreClick,
  onDeleteClick,
}: {
  onRestoreClick(e: React.MouseEvent): void;
  onDeleteClick(e: React.MouseEvent): void;
}) => (
  <Fragment>
    <div className="level-item is-hidden-mobile">
      <button className="button is-primary" onClick={onRestoreClick}>
        <span
          className="icon is-medium"
          aria-label="Restore"
          data-balloon-pos="down"
        >
          <i className="fa fa-recycle fa-lg" />
        </span>
      </button>
    </div>
    <div className="level-item is-hidden-mobile">
      <button className="button is-danger" onClick={onDeleteClick}>
        <span
          className="icon is-medium"
          aria-label="Delete for good"
          data-balloon-pos="down"
        >
          <i className="fa fa-trash fa-lg" />
        </span>
      </button>
    </div>
  </Fragment>
);

interface Props {
  item: Item;
  store: ItemStore;
}

@observer
class ItemBox extends React.Component<Props> {
  readonly itemBoxDiv = React.createRef<HTMLDivElement>();

  onRestoreClick = (e: React.MouseEvent) => {
    e.preventDefault();
    this.props.store.restore(this.props.item);
  };

  onDeleteClick = (e: React.MouseEvent) => {
    e.preventDefault();
    this.props.store.delete(this.props.item);
  };

  onTagClick = (e: React.MouseEvent, tag: Tag) => {
    e.preventDefault();
    const options = e.metaKey ? { append: true } : {};
    this.props.store.addTagFilter(tag, options);
  };

  onItemNameClick = (e: React.MouseEvent) => {
    e.preventDefault();
    this.props.store.focusItem(this.props.item);
    this.props.store.showItemDetails(this.props.item);
  };

  componentDidUpdate() {
    const { item, store } = this.props;
    const currentItemBoxDiv = this.itemBoxDiv.current;

    if (!store.isFocused(item) || !currentItemBoxDiv) {
      return;
    }

    scrollIntoView(currentItemBoxDiv, {
      behavior: 'smooth',
      scrollMode: 'if-needed',
    });
  }

  render() {
    const { item, store } = this.props;

    const thumbUrl = item!.image?.thumb?.url ?? '';

    let itemRatingClassName =
      'level-item is-hidden-mobile item-rating show-on-hover has-pointer';

    if (!item.rating) {
      itemRatingClassName = `${itemRatingClassName} hidden`;
    }

    const itemRatingProps = { className: itemRatingClassName };
    (itemRatingProps as any)['aria-label'] = item.rating
      ? `Show items rated "${RATING_NAMES[item.rating - 1]}"`
      : 'Show unrated items';

    (itemRatingProps as any)['onClick'] = item.rating
      ? (e: React.MouseEvent) =>
          this.onTagClick(e, {
            name: `${item.rating}/5`,
            value: item.rating,
            type: 'rating',
          })
      : (e: React.MouseEvent) =>
          this.onTagClick(e, {
            name: `Unrated`,
            value: item.rating,
            type: 'rating',
          });

    return (
      <div
        className={`box item-box ${store.isFocused(item) && 'is-focused'}`}
        ref={this.itemBoxDiv}
      >
        <div className="level is-mobile">
          <div className="level-left is-mobile">
            <div className="level-item">
              <figure className="image is-64x64">
                <img
                  src={thumbUrl ? publicAssetsUrl(thumbUrl) : ''}
                  alt=""
                  className="item-cover"
                />
              </figure>
            </div>

            <div className="level-item title-item item-name">
              <div className="subtitle is-5">
                <a href="/" onClick={this.onItemNameClick} title={item.original_name}>
                  {item.name}
                </a>
              </div>
            </div>

            {item.year && (
              <div
                className="level-item has-pointer item-year"
                onClick={(e) =>
                  this.onTagClick(e, {
                    name: item.year.toString(),
                    value: item.year,
                    type: 'year',
                  })
                }
                aria-label={`Show ${item.year} items`}
                data-balloon-pos="down"
              >
                <span className="tag is-rounded is-light is-small">
                  {item.year}
                </span>
              </div>
            )}

            {item.deleted && (
              <div className="level-item has-pointer is-hidden-mobile">
                <span className="tag is-rounded is-light is-small">
                  {item.list}
                </span>
              </div>
            )}

            {item.tags.map((tag) => (
              <div
                key={`item-tag-${tag}`}
                className="level-item is-hidden-touch has-pointer"
                onClick={(e) =>
                  this.onTagClick(e, { name: tag, value: tag, type: 'tag' })
                }
                aria-label={`Show ${tag} items`}
                data-balloon-pos="down"
              >
                <span className="tag is-rounded is-light is-small">{tag}</span>
              </div>
            ))}

            {item.status !== 'todo' && (
              <div className="level-item is-hidden-touch">
                <span
                  className={`tag is-rounded is-small has-pointer ${
                    item.status === 'doing' ? 'is-warning' : 'is-success'
                  }`}
                  onClick={(e) =>
                    this.onTagClick(e, {
                      name: _.capitalize(item.status),
                      value: item.status,
                      type: 'status',
                    })
                  }
                >
                  {item.human_status}
                </span>
              </div>
            )}

            <div {...itemRatingProps}>
              <ItemRating
                item={item}
                onUpdateRating={store.updateRating}
                readonly
              />
            </div>
          </div>

          <div className="level-right is-mobile item-actions hidden">
            {!item.deleted && (
              <>
                <div className="level-item is-hidden-mobile">
                  <a target="blank" href={urls.pirateSearchUrl(item)}>
                    <span
                      className="icon is-medium"
                      aria-label="Search the Bay"
                      data-balloon-pos="down"
                    >
                      <i className="fa fa-magnet fa-lg" />
                    </span>
                  </a>
                </div>

                <div className="level-item is-hidden-mobile">
                  <a target="blank" href={urls.googleSearchUrl(item)}>
                    <span
                      className="icon is-medium"
                      aria-label="Search Google"
                      data-balloon-pos="down"
                    >
                      <i className="fab fa-google fa-lg" />
                    </span>
                  </a>
                </div>

                <div className="level-item is-hidden-mobile">
                  <a target="blank" href={urls.youtubeSearchUrl(item)}>
                    <span
                      className="icon is-medium"
                      aria-label="Search YouTube"
                      data-balloon-pos="down"
                    >
                      <i className="fab fa-youtube fa-lg" />
                    </span>
                  </a>
                </div>

                <div className="level-item is-hidden-mobile">
                  <a target="blank" href={urls.netflixSearchUrl(item)}>
                    <span
                      className="icon is-medium"
                      aria-label="Search Netflix"
                      data-balloon-pos="down"
                    >
                      <i className="fa fa-tv fa-lg" />
                    </span>
                  </a>
                </div>
              </>
            )}
            {item.deleted && (
              <RestoreActions
                onRestoreClick={this.onRestoreClick}
                onDeleteClick={this.onDeleteClick}
              />
            )}
          </div>
        </div>
      </div>
    );
  }
}

export default ItemBox;
