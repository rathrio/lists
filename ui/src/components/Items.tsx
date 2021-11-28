import React, { Fragment } from 'react';

import OmniBar from './OmniBar';
import ItemList from './ItemList';
import ScraperResultsContent from './ScraperResultsContent';
import ItemDetails from './ItemDetails';
import RootStore from '../stores/RootStore';

function Items(props: { store: RootStore }) {
  const itemStore = props.store.itemStore;

  return (
    <Fragment>
      <OmniBar store={itemStore} />
      <ItemList store={itemStore} />
      <ScraperResultsContent store={itemStore} />
      <ItemDetails store={itemStore} />
    </Fragment>
  );
}

export default Items;
