import React from 'react';
import { ScraperResult } from '..';

interface Props {
  result: ScraperResult;
  onAdd(result: ScraperResult): void;
}

const ScraperResultBox = ({ result, onAdd }: Props) => {
  const thumbUrl = result.remote_image_url;
  const date = result.date;
  const year = new Date(date).getFullYear();
  const tags = result.tags.slice(0, 4);

  const onClick = (e: React.MouseEvent) => onAdd(result);

  return (
    <div
      className="box item-box scraper-result has-pointer"
      data-balloon="Add to List"
      onClick={onClick}
    >
      <div className="level is-mobile">
        <div className="level-left is-mobile">
          <div className="level-item">
            <figure className="image is-64x64">
              <img
                src={thumbUrl}
                style={{ width: '64px', height: '64px', objectFit: 'cover' }}
                alt={result.name}
              />
            </figure>
          </div>

          <div className="level-item">
            <div className="subtitle is-4">{result.name}</div>
          </div>

          <div className="level-item">
            <span className="tag is-rounded is-light is-small">{year}</span>
          </div>

          {tags.map((tag) => (
            <div
              key={`scraper-result-tag-${tag}`}
              className="level-item is-hidden-touch item-tag"
            >
              <span className="tag is-rounded is-light is-small">{tag}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default ScraperResultBox;
