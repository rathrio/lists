import React, { Fragment } from 'react';
import { observer } from 'mobx-react';
import * as Mousetrap from 'mousetrap';

import ItemStore from '../stores/ItemStore';
import { Tag } from '..';
import StarRating, { RATING_NAMES } from './StarRating';
import { action } from 'mobx';

interface TagContentProps {
  tag: Tag;
}

class TagContent extends React.Component<TagContentProps> {
  @action
  updateTagValue = (value: number | string | undefined) => {
    this.props.tag.value = value;
  };

  ratingBalloonMessage = (rating: number) => {
    if (rating) {
      return `Show items rated "${RATING_NAMES[rating - 1]}"`;
    }

    return 'Show unrated items';
  };

  render() {
    const { tag } = this.props;

    return (
      <Fragment>
        {tag.type === 'rating' ? (
          <StarRating
            rating={tag.value as number | undefined}
            onStarClick={this.updateTagValue}
            balloonMessage={this.ratingBalloonMessage}
          />
        ) : (
          tag.name
        )}
      </Fragment>
    );
  }
}

interface Props {
  store: ItemStore;
}

@observer
class OmniBar extends React.Component<Props> {
  readonly inputField = React.createRef<HTMLInputElement>();

  constructor(props: Props) {
    super(props);

    Mousetrap.bind('/', (e) => {
      e.preventDefault();

      this.searchField.focus();
      this.searchField.select();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  onKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    const { store } = this.props;

    switch (e.keyCode) {
      case 9: // Tab to focus first filtered item
        e.preventDefault();
        store.focusNextItem();
        this.searchField.blur();
        return false;

      case 8: // Backspace to remove last tag
        if (store.query || store.tags.length === 0) {
          return true;
        }
        e.preventDefault();

        // CMD/CTRL + Backspace should clear all tags
        if (e.metaKey) {
          store.clearTagFilter();
        } else {
          store.popTagFilter();
        }

      default:
        return true;
    }
  };

  onChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    this.props.store.filter(e.target.value);
  };

  onSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    this.props.store.scrape();
  };

  get searchField(): HTMLInputElement {
    const currentField = this.inputField.current;
    if (!currentField) {
      throw new Error('OmniBar not ready');
    }

    return currentField;
  }

  tagClass = (tag: Tag): string => {
    if (tag.type !== 'status' || tag.value === 'todo') {
      return '';
    }

    return tag.value === 'doing' ? 'is-warning' : 'is-success';
  };

  render() {
    const { store } = this.props;

    return (
      <form onSubmit={this.onSubmit}>
        <div className="omni-bar">
          <div className="tags">
            {store.tags.map((tag) => (
              <span
                className={`tag is-light is-rounded ${this.tagClass(tag)}`}
                key={tag.value}
              >
                <TagContent tag={tag} />

                <button
                  className="delete is-small"
                  onClick={() => store.removeTagFilter(tag)}
                />
              </span>
            ))}
          </div>

          <input
            ref={this.inputField}
            value={store.query}
            onChange={this.onChange}
            onKeyDown={this.onKeyDown}
            placeholder="Search"
            autoComplete="off"
            type="text"
          />
        </div>
      </form>
    );
  }
}

export default OmniBar;
