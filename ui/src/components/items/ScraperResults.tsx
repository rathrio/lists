import { useState } from 'react';
import { ScraperResult } from '../../interfaces';
import RootStore from '../../stores/RootStore';
import CoverBox from './CoverBox';

interface ScraperResultBoxProps {
  result: ScraperResult;
  store: RootStore;
}

const ScraperResultBox = ({ result, store }: ScraperResultBoxProps) => {
  const [isImporting, setIsImporting] = useState(false);

  const thumbUrl = result.remote_image_url;
  const date = result.date;
  const year = new Date(date).getFullYear();
  const coverAspectRatio =
    store.listStore.activeList?.cover_aspect_ratio ?? '2by3';

  return (
    <CoverBox
      coverUrl={thumbUrl}
      isCoverMissing={!thumbUrl}
      title={result.name}
      coverAspectRatio={coverAspectRatio}
      isLoading={isImporting}
      onClick={() => {
        if (isImporting) return;
        setIsImporting(true);
        store.itemStore.importScraperResult(result).finally(() => {
          setIsImporting(false);
        });
      }}
      balloonMessage="Add to List"
    >
      <p>{year}</p>
    </CoverBox>
  );
};

interface Props {
  store: RootStore;
}

const ScraperResults = ({ store }: Props) => {
  const resultsList = store.itemStore.scraperResults.map((result, index) => (
    <ScraperResultBox
      key={`scraper-result-${result.name}-${result.date}-${index}`}
      result={result}
      store={store}
    />
  ));

  return (
    <>
      <h4 className="subtitle is-4" style={{ marginTop: '1.5rem' }}>
        Found on the interwebs
      </h4>
      <div className="items-grid">{resultsList}</div>
    </>
  );
};

export default ScraperResults;
