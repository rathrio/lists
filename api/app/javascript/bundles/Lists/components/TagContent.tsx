import React, { Fragment } from 'react';
import StarRating, { RATING_NAMES } from './StarRating';
import { action } from 'mobx';

import { Tag } from '..';

interface Props {
  tag: Tag;
}

/**
 * Renders content for an Omnibar filter tag.
 */
class TagContent extends React.Component<Props> {
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

export default TagContent;
