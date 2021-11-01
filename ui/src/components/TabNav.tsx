import { observer } from 'mobx-react';
import RootStore from '../stores/RootStore';

function TabNav(props: { store: RootStore }) {
  const listStore = props.store.listStore;
  const lists = listStore.lists;
  const activeList = listStore.activeList;

  const navStore = props.store.navStore;

  return (
    <div className="tabs is-medium is-fullwidth topnav-tabs">
      <ul>
        {lists.map((list) => (
          <li
            key={list.name}
            className={
              navStore.currentView === 'items' && list.id === activeList?.id
                ? 'is-active'
                : ''
            }
          >
            <a onClick={() => navStore.showList(list)}>
              <span className="icon">
                <i className={`fa fa-${list.fa_icon}`} />
              </span>
              <span>{list.name}</span>
            </a>
          </li>
        ))}

        <li className={navStore.currentView === 'settings' ? 'is-active' : ''}>
          <a onClick={() => navStore.showSettings()}>
            <span className="icon">
              <i className="fa fa-cog" />
            </span>
            <span>Settings</span>
          </a>
        </li>
      </ul>
    </div>
  );
}

export default observer(TabNav);
