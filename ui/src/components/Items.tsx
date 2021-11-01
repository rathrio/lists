import React, { Fragment } from 'react';

import OmniBar from './OmniBar';
import ItemList from './ItemList';
import ItemStore from '../stores/ItemStore';
import ScraperResultsContent from './ScraperResultsContent';
import ItemDetails from './ItemDetails';
import RootStore from '../stores/RootStore';

interface Props {
  store: RootStore;
}

class Items extends React.Component<Props> {
  store: ItemStore;

  constructor(props: Props) {
    super(props);
    this.store = props.store.itemStore;
  }

  render() {
    return (
      <Fragment>
        <OmniBar store={this.store} />
        <ItemList store={this.store} />
        <ScraperResultsContent store={this.store} />
        <ItemDetails store={this.store} />
      </Fragment>
    );
  }
}

export default Items;
