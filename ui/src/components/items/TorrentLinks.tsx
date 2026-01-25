import React from 'react';
import { observer } from 'mobx-react';
import { Item } from '../../interfaces';
import ItemStore from '../../stores/ItemStore';
import CollapsibleSection from './CollapsibleSection';

interface Props {
  item: Item;
  store: ItemStore;
}

const TorrentLinks = observer((props: React.PropsWithChildren<Props>) => {
  const { item, store } = props;

  if (!item.supports_torrents) {
    return null;
  }

  const hasLinks = !!item.torrent_links?.length;
  const isLoading = store.isRefreshingTorrents;

  const onRefreshClick = (e: React.MouseEvent) => {
    e.preventDefault();
    store.refreshTorrents();
  };

  const refreshButton = (
    <button
      type="button"
      className={`button is-small ${isLoading ? 'is-loading' : ''}`}
      onClick={onRefreshClick}
      disabled={isLoading}
    >
      <span className="icon">
        <i className="fas fa-magnet" />
      </span>
      <span>Refresh</span>
    </button>
  );

  return (
    <CollapsibleSection title="Torrents">
      {hasLinks && (
        <table className="table is-narrow is-fullwidth mb-3">
          <thead>
            <tr>
              <th>Title</th>
              <th>Size</th>
              <th>Seeders</th>
              <th>Magnet</th>
            </tr>
          </thead>
          <tbody>
            {item.torrent_links?.map((link, index) => (
              <tr key={index}>
                <td>{link.title}</td>
                <td>{link.size}</td>
                <td>{link.seeders}</td>
                <td>
                  {link.magnet && (
                    <a href={link.magnet}>
                      <span className="icon">
                        <i className="fas fa-magnet" />
                      </span>
                    </a>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
        {refreshButton}
      </div>
    </CollapsibleSection>
  );
});

export default TorrentLinks;
