import { Fragment } from 'react';
import { observer } from 'mobx-react';
import ScraperResults from './ScraperResults';
import RootStore from '../../stores/RootStore';
import Spinner from '../elements/Spinner';

interface Props {
  store: RootStore;
}

function ScraperResultsContent(props: Props) {
  const { store } = props;

  const scraperResults =
    store.itemStore.scraperResults.length > 0 ? (
      <ScraperResults store={store} />
    ) : (
      ''
    );

  const spinner = store.itemStore.spinnerVisible ? <Spinner /> : '';

  return (
    <Fragment>
      {spinner}
      {scraperResults}
    </Fragment>
  );
}

export default observer(ScraperResultsContent);
