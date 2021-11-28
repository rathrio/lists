import React, { Fragment } from 'react';
import { observer } from 'mobx-react';
import { action, computed, makeObservable, observable } from 'mobx';

import { Item } from '../interfaces';

export const RATING_NAMES = ['Abysmal', 'Poor', 'Good', 'Great', 'Masterful'];

interface Props {
  item: Item;
  onUpdateRating(item: Item, rating: number): void;
  readonly?: boolean;
}

interface State {
  rating: number;
}

// TODO switch to functional component with state hooks instead of mobx observables.
@observer
class ItemRating extends React.Component<Props, State> {
  @observable
  rating?: number;

  private readonly = false;

  constructor(props: Props) {
    super(props);
    makeObservable(this);

    if (props.readonly) {
      this.readonly = true;
    }
  }

  @computed
  get currentRating(): number {
    return this.rating || this.props.item.rating || 0;
  }

  @action
  onStarEnter = (rating: number) => {
    if (this.readonly) {
      return;
    }

    this.rating = rating;
  };

  @action
  onStarLeave = (rating: number) => {
    if (this.readonly) {
      return;
    }

    this.rating = this.props.item.rating || 0;
  };

  @action
  onStarClick = (rating: number) => {
    if (this.readonly) {
      return;
    }

    this.props.onUpdateRating(this.props.item, rating);
  };

  renderStar = (n: number) => {
    const starIcon = n <= this.currentRating ? 'fas fa-star' : 'far fa-star';
    const className = `${starIcon} fa-sm item-rating-star ${
      this.readonly ? '' : 'has-pointer'
    }`;

    const spanProps = this.readonly
      ? {}
      : { 'aria-label': RATING_NAMES[n - 1], 'data-balloon-pos': 'down' };

    return (
      <span key={n} {...spanProps}>
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
      <Fragment>{[1, 2, 3, 4, 5].map((n) => this.renderStar(n))}</Fragment>
    );
  }
}

export default ItemRating;
