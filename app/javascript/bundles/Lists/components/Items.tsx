import React, { Fragment } from 'react';
import * as Mousetrap from 'mousetrap';

import API from '../../utils/api';
import Rails from '../../utils/rails';
import OmniBar from './OmniBar';
import ItemList from './ItemList';
import { Item } from '..';
import ItemStore from '../stores/ItemStore';
import ScraperResultsContent from './ScraperResultsContent';
import ItemDetails from './ItemDetails';

interface Props {
  readonly items: Item[];
}

/**
 * Entry component for react on rails. Should not be a mobx observer. Handles
 * store and auth setup.
 */
class Items extends React.Component<Props> {
  store: ItemStore;

  constructor(props: Props) {
    super(props);
    this.store = new ItemStore(props.items);
    (window as any).store = this.store;

    Mousetrap.bind('r', (e) => {
      e.preventDefault();
      this.store.showRandomItemDetails();
    });

    Mousetrap.bind('t', (e) => {
      if (this.store.detailsModalVisible) {
        return;
      }

      e.preventDefault();
      this.store.toggleItemStatusFilter();
    });

    Mousetrap.bind('enter', (e) => {
      e.preventDefault();
      this.store.showFocusedItemDetails();
    });

    Mousetrap.bind(['j', 'tab'], (e) => {
      // Tab should only work outside of details modal.
      if (this.store.detailsModalVisible && e.key === 'Tab') {
        return;
      }

      e.preventDefault();
      this.store.focusNextItem();
    });

    Mousetrap.bind(['k', 'shift+tab'], (e) => {
      // Tab should only work outside of details modal.
      if (this.store.detailsModalVisible && e.key === 'Tab') {
        return;
      }

      e.preventDefault();
      this.store.focusPreviousItem();
    });
  }

  componentDidMount() {
    const csrfToken = Rails.authenticityToken();
    API.defaults.headers.common['X-CSRF-Token'] = csrfToken;
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
