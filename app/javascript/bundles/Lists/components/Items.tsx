import React, { Fragment } from 'react';
import * as Mousetrap from 'mousetrap';

import API from '../../utils/api';
import Rails from '../../utils/Rails';
import OmniBar from './OmniBar';
import ItemList from './ItemList';
import { Item } from '..';
import ItemStore from '../stores/ItemStore';
import ScraperResultsContent from './ScraperResultsContent';

interface Props {
  readonly items: Item[];
}

/**
 * Entry component for react on rails. Should not be an mobx observer. Handles
 * store and auth setup.
 */
class Items extends React.Component<Props> {
  store: ItemStore;

  constructor(props: Props) {
    super(props);
    this.store = new ItemStore(props.items);
    (window as any).store = this.store;
  }

  componentDidMount() {
    const csrfToken = Rails.authenticityToken();
    API.defaults.headers.common['X-CSRF-Token'] = csrfToken;

    Mousetrap.bind('s', this.store.toggleItemStatusFilter);
  }

  render() {
    return (
      <Fragment>
        <OmniBar store={this.store} />
        <ItemList store={this.store} />
        <ScraperResultsContent store={this.store} />
      </Fragment>
    );
  }
}

export default Items;
