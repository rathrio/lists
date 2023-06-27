import { observer } from 'mobx-react';
import React from 'react';
import { CoverAspectRatio } from '../../interfaces';

interface Props {
  coverUrl: string;
  title: string;
  isCoverMissing?: boolean;
  coverAspectRatio: CoverAspectRatio;
  isFocused?: boolean;
  tag?: string;
  tagClass?: string;
  balloonMessage?: string;
  disablePointer?: boolean;
  className?: string;
  onClick: () => void;
}

const CoverBox = observer((props: React.PropsWithChildren<Props>) => {
  return (
    <div
      className={`cover-box${props.isFocused ? ' is-focused' : ''} ${
        props.className
      }`}
      style={{ position: 'relative' }}
      aria-label={props.balloonMessage}
      data-balloon-pos="down"
    >
      <figure
        className={`image is-${props.coverAspectRatio} ${
          props.disablePointer ? '' : 'has-pointer'
        } ${props.isCoverMissing ? 'is-placeholder' : ''}`}
        onClick={props.onClick}
      >
        {props.isCoverMissing ? (
          <p className="placeholder-title">{props.title}</p>
        ) : (
          <img
            src={props.coverUrl}
            alt="TODO: Fix me and render a title instead of an img"
          />
        )}
      </figure>

      {props.tag && (
        <span
          className={`status-tag tag is-small ${props.tagClass}`}
          data-balloon-pos="down"
        >
          {props.tag}
        </span>
      )}

      <div className="cover-box-info">{props.children}</div>
    </div>
  );
});

export default CoverBox;
