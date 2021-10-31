import React, { Fragment } from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';
import Spinner from './Spinner';
import ScraperResults from './ScraperResults';

interface Props {
  store: ItemStore;
}

@observer
class ScraperResultsContent extends React.Component<Props> {
  render() {
    const { store } = this.props;

    const scraperResults =
      store.scraperResults.length > 0 ? (
        <ScraperResults
          results={store.scraperResults}
          onAdd={store.importScraperResult}
        />
      ) : (
          ''
        );

    const spinner = store.spinnerVisible ? <Spinner /> : '';

    return (
      <Fragment>
        {spinner}
        {scraperResults}
      </Fragment>
    );
  }
}

export default ScraperResultsContent;
