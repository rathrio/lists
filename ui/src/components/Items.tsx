import React, { Fragment } from 'react';

import OmniBar from './OmniBar';
import ItemList from './ItemList';
import ScraperResultsContent from './ScraperResultsContent';
import ItemDetails from './ItemDetails';
import RootStore from '../stores/RootStore';
import ItemGrid from './ItemGrid';

function Items(props: { store: RootStore }) {
  const itemStore = props.store.itemStore;

  return (
    <Fragment>
      <OmniBar store={itemStore} />
      {/* <ItemList store={itemStore} /> */}
      <ItemGrid store={props.store} />
      <ScraperResultsContent store={itemStore} />
      <ItemDetails store={props.store} />
    </Fragment>
  );
}

export default Items;
