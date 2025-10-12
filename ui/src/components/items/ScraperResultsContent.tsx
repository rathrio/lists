import { Fragment } from 'react';
import { observer } from 'mobx-react';
import ScraperResults from './ScraperResults';
import RootStore from '../../stores/RootStore';
import PlaceholderGrid from './PlaceholderGrid';

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

  const aspectRatio = store.listStore.activeList?.cover_aspect_ratio ?? '2by3';
  const placeholderGrid = store.itemStore.spinnerVisible ? (
    <>
      <h4 className="subtitle is-4" style={{ marginTop: '1.5rem' }}>
        Found on the interwebs
      </h4>
      <PlaceholderGrid aspectRatio={aspectRatio} numBoxes={27} />
    </>
  ) : (
    ''
  );

  return (
    <Fragment>
      {placeholderGrid}
      {scraperResults}
    </Fragment>
  );
}

export default observer(ScraperResultsContent);
