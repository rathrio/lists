import React from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../../stores/ItemStore';

// Jellyseerr media status values.
const PENDING = 2;
const PROCESSING = 3;
const PARTIALLY_AVAILABLE = 4;
const AVAILABLE = 5;

interface Props {
  store: ItemStore;
}

/**
 * One Availability row driven by Jellyseerr state — a request button, a
 * progress note, or a watch link, never more than one primary action.
 * Renders nothing when availability is unknown (no TMDB id, Jellyseerr
 * unreachable).
 */
const Availability = observer(({ store }: Props) => {
  const availability = store.availability;

  if (!availability) {
    return null;
  }

  const requestButton = (label: string, primary = true) => (
    <button
      type="button"
      className={`button ${primary ? 'is-primary' : 'is-small'} ${
        store.isRequestingDownload ? 'is-loading' : ''
      }`}
      onClick={(e) => {
        e.preventDefault();
        store.requestDownload();
      }}
      disabled={store.isRequestingDownload}
    >
      <span className="icon">
        <i className="fas fa-download" />
      </span>
      <span>{label}</span>
    </button>
  );

  const watchButton = availability.watch_url && (
    <a
      className="button is-primary"
      href={availability.watch_url}
      target="_blank"
      rel="noreferrer"
    >
      <span className="icon">
        <i className="fas fa-play" />
      </span>
      <span>Watch in Jellyfin</span>
    </a>
  );

  const availableSince = availability.available_since && (
    <p className="help">
      Available since{' '}
      {new Date(availability.available_since).toLocaleDateString()}
    </p>
  );

  let content: React.ReactNode;
  switch (availability.status) {
    case PENDING:
      content = (
        <p>
          <strong>Download:</strong> requested
        </p>
      );
      break;
    case PROCESSING:
      content = (
        <p>
          <strong>Download:</strong> in progress…
        </p>
      );
      break;
    case PARTIALLY_AVAILABLE:
      content = (
        <>
          {watchButton}
          <p className="help">Some seasons are missing</p>
          <div className="mt-2">
            {requestButton('Request remaining seasons', false)}
          </div>
        </>
      );
      break;
    case AVAILABLE:
      content = (
        <>
          {watchButton}
          {availableSince}
        </>
      );
      break;
    default:
      // null or 1 ("unknown") — never requested.
      content = (
        <>
          {requestButton('Request download')}
          <p className="help">Asks Jellyseerr to find and download this</p>
        </>
      );
  }

  return (
    <div className="item-availability mt-5">
      {content}
      {store.availabilityError && (
        <p className="help has-text-danger">{store.availabilityError}</p>
      )}
    </div>
  );
});

export default Availability;
