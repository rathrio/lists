import React, { Fragment } from 'react';
import { Item } from '..';
import { observer } from 'mobx-react';
import { observable } from 'mobx';

interface Props {
  item: Item;
  onUpdateRating(item: Item, rating: number): void;
}

interface State {
  rating: number;
}

@observer
class ItemRating extends React.Component<Props, State> {
  @observable
  rating: number = this.props.item.rating || 0;

  private readonly ratingNames = ['Abysmal', 'Poor', 'Good', 'Great', 'Masterful'];

  onStarEnter = (rating: number) => {
    this.rating = rating;
  };

  onStarLeave = (rating: number) => {
    this.rating = this.props.item.rating || 0;
  };

  onStarClick = (rating: number) => {
    this.props.onUpdateRating(this.props.item, rating);
  };

  renderStar = (n: number) => {
    const starIcon = n <= this.rating ? 'fa-star' : 'fa-star-o';
    const className = `fa ${starIcon} fa-sm has-pointer item-rating-star`;
    return (
      <span key={n} data-balloon={this.ratingNames[n - 1]}>
        <i
          className={className}
          onMouseEnter={() => this.onStarEnter(n)}
          onMouseLeave={() => this.onStarLeave(n)}
          onMouseDown={() => this.onStarClick(n)}
        />
      </span>
    );
  };

  render() {
    return (
      <Fragment>
        {[1, 2, 3, 4, 5].map((n) => this.renderStar(n))}
      </Fragment>
    );
  }
}

export default ItemRating;
