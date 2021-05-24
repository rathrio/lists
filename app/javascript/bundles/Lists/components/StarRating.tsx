import React, { Fragment } from 'react';
import { observer } from 'mobx-react';
import { observable, computed, action } from 'mobx';

export const RATING_NAMES = ['Abysmal', 'Poor', 'Good', 'Great', 'Masterful'];

interface Props {
  rating?: number;
  onStarClick?(n: number): void;
  balloonMessage?(rating: number): string;
}

/**
 * Interactive star rating rendered in omnibar.
 * TODO: Find a way to get rid of duplication with ItemRating.
 */
@observer
class StarRating extends React.Component<Props> {
  @observable
  rating?: number;

  @computed
  get currentRating(): number {
    return this.rating || this.props.rating || 0;
  }

  @action
  onStarEnter = (rating: number) => {
    this.rating = rating;
  };

  @action
  onStarLeave = (rating: number) => {
    this.rating = this.props.rating || 0;
  };

  onStarClick = (rating: number) => {
    if (!this.props.onStarClick) {
      return;
    }

    this.props.onStarClick(rating);
  };

  balloonMessage = (rating: number) => {
    if (!this.props.balloonMessage) {
      return RATING_NAMES[rating - 1];
    }

    return this.props.balloonMessage(rating);
  };

  renderStar = (rating: number) => {
    const starIcon = rating <= this.currentRating ? 'fa-star' : 'fa-star-o';
    const className = `fa ${starIcon} fa-sm item-rating-star has-pointer`;

    const spanProps = {
      'aria-label': this.balloonMessage(rating)
    };

    return (
      <span key={rating} {...spanProps}>
        <i
          className={className}
          onMouseEnter={() => this.onStarEnter(rating)}
          onMouseLeave={() => this.onStarLeave(rating)}
          onMouseDown={() => this.onStarClick(rating)}
        />
      </span>
    );
  };

  render() {
    return (
      <Fragment>
        {[1, 2, 3, 4, 5].map((rating) => this.renderStar(rating))}
      </Fragment>
    );
  }
}

export default StarRating;
