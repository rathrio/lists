import React, { Fragment } from 'react';

import OmniBar from './OmniBar';
import ScraperResultsContent from './ScraperResultsContent';
import ItemDetails from './ItemDetails';
import ItemGrid from './ItemGrid';
import RootStore from '../../stores/RootStore';

function Items(props: { store: RootStore }) {
  const itemStore = props.store.itemStore;

  return (
    <Fragment>
      <OmniBar store={itemStore} />
      <ItemGrid store={props.store} />
      <ScraperResultsContent store={props.store} />
      <ItemDetails store={props.store} />
    </Fragment>
  );
}

export default Items;
