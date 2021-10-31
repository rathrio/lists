import React from 'react';
import { ScraperResult } from '../interfaces';
import ScraperResultBox from './ScraperResultBox';

interface Props {
  results: ScraperResult[];
  onAdd(result: ScraperResult): void;
}

const ScraperResults = ({ results, onAdd }: Props) => {
  const resultsList = results.map((result) => (
    <ScraperResultBox
      key={`scraper-result-${result.name}-${result.date}`}
      result={result}
      onAdd={onAdd}
    />
  ));

  return (
    <div className="scraper-results">
      <h4 className="subtitle is-4">Found on the interwebs</h4>
      {resultsList}
    </div>
  );
};

export default ScraperResults;
