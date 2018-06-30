import React from 'react';
import { Item } from '..';

interface Props {
  item: Item;
  onUpdateRating(item: Item, rating: number): void;
}

interface State {
  rating: number;
}

class ItemRating extends React.Component<Props, State> {
  readonly state: State = {
    rating: this.props.item.rating || 0
  };

  private readonly ratingNames = ['Abysmal', 'Poor', 'Good', 'Great', 'Masterful'];

  onStarEnter = (rating: number) => {
    this.setState({ rating });
  };

  onStarLeave = (rating: number) => {
    this.setState({ rating: this.props.item.rating || 0 });
  };

  onStarClick = (rating: number) => {
    this.props.onUpdateRating(this.props.item, rating);
  };

  renderStar = (n: number) => {
    const starIcon = n <= this.state.rating ? 'fa-star' : 'fa-star-o';
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
      <div className="level-item is-hidden-mobile item-rating">
        {[1, 2, 3, 4, 5].map((n) => this.renderStar(n))}
      </div>
    );
  }
}

export default ItemRating;
