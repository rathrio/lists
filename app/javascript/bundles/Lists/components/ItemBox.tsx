import React, { Fragment } from 'react';
import { observer } from 'mobx-react';
import scrollIntoView from 'scroll-into-view-if-needed';

import { Item } from '..';
import ItemRating, { RATING_NAMES } from './ItemRating';
import * as urls from '../../utils/external_item_urls';
import ItemStore from '../stores/ItemStore';

const RestoreActions = ({
  onRestoreClick,
  onDeleteClick
}: {
  onRestoreClick(e: React.MouseEvent): void;
  onDeleteClick(e: React.MouseEvent): void;
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
  store: ItemStore;
}

/**
 * Technically a Bulma level element.
 */
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

  onTagClick = (e: React.MouseEvent, tag: string) => {
    const options = e.metaKey ? { append: true } : {};
    this.props.store.onTagFilter(tag, options);
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
      scrollMode: 'if-needed'
    });
  }

  render() {
    const { item, store } = this.props;

    const thumbUrl = item!.image!.thumb.url;

    let itemRatingClassName =
      'level-item is-hidden-mobile item-rating show-on-hover has-pointer';

    if (!item.rating) {
      itemRatingClassName = `${itemRatingClassName} hidden`;
    }

    const itemRatingProps = { className: itemRatingClassName };
    (itemRatingProps as any)['data-balloon'] = item.rating
      ? `Show items rated "${RATING_NAMES[item.rating - 1]}"`
      : 'Show unrated items';

    return (
      <div
        className={`box item-box ${store.isFocused(item) && 'is-focused'}`}
        ref={this.itemBoxDiv}
      >
        <div className="level is-mobile" style={{ overflowX: 'clip' }}>
          <div className="level-left is-mobile">
            <div className="level-item">
              <figure className="image is-64x64">
                <img src={thumbUrl} alt={item.name} className="item-cover" />
              </figure>
            </div>

            <div className="level-item title-item item-name">
              <div className="subtitle is-5">
                <a onClick={this.onItemNameClick}>{item.name}</a>
              </div>
            </div>

            {item.year && (
              <div
                className="level-item has-pointer item-year"
                onClick={(e) => this.onTagClick(e, `y[${item.year}]`)}
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
                onClick={(e) => this.onTagClick(e, `t[${tag}]`)}
                data-balloon={`Show ${tag} items`}
              >
                <span className="tag is-rounded is-light is-small">{tag}</span>
              </div>
            ))}

            {item.status !== 'todo' && (
              <div className="level-item is-hidden-touch">
                <span
                  className={`tag is-rounded is-small ${
                    item.status === 'doing' ? 'is-warning' : 'is-success'
                  }`}
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
            <div className="level-item is-hidden-mobile">
              <a target="blank" href={urls.pirateSearchUrl(item)}>
                <span className="icon is-medium" data-balloon="Search the Bay">
                  <i className="fa fa-magnet fa-lg" />
                </span>
              </a>
            </div>

            <div className="level-item is-hidden-mobile">
              <a target="blank" href={urls.googleSearchUrl(item)}>
                <span className="icon is-medium" data-balloon="Search Google">
                  <i className="fa fa-google fa-lg" />
                </span>
              </a>
            </div>

            <div className="level-item is-hidden-mobile">
              <a target="blank" href={urls.youtubeSearchUrl(item)}>
                <span className="icon is-medium" data-balloon="Search YouTube">
                  <i className="fa fa-youtube-play fa-lg" />
                </span>
              </a>
            </div>

            <div className="level-item is-hidden-mobile">
              <a target="blank" href={urls.netflixSearchUrl(item)}>
                <span className="icon is-medium" data-balloon="Search Netflix">
                  <i className="fa fa-tv fa-lg" />
                </span>
              </a>
            </div>

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
