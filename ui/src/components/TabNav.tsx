import { observer } from 'mobx-react';
import RootStore from '../stores/RootStore';
import { useEffect, useRef } from 'react';
import scrollIntoView from 'scroll-into-view-if-needed';

interface TabLinkProps {
  onClick: () => void;
  name: string;
  faIcon: string;
  isActive: boolean;
}

function TabLink(props: TabLinkProps) {
  const liRef = useRef(null);

  useEffect(() => {
    const element = liRef.current as any;
    if (element?.className.includes('is-active')) {
      scrollIntoView(element);
    }
  });

  return (
    <li ref={liRef} className={props.isActive ? 'is-active' : ''}>
      <a onClick={props.onClick}>
        <span className="icon">
          <i className={`fa fa-${props.faIcon}`} />
        </span>
        <span>{props.name}</span>
      </a>
    </li>
  );
}

function TabNav(props: { store: RootStore }) {
  const listStore = props.store.listStore;
  const lists = listStore.lists;
  const activeList = listStore.activeList;
  const navStore = props.store.navStore;

  return (
    <div className="tabs is-medium is-fullwidth topnav-tabs">
      <ul>
        {lists.map((list) => (
          <TabLink
            key={list.name}
            isActive={
              navStore.currentView === 'items' && list.id === activeList?.id
            }
            onClick={() => navStore.showList(list)}
            name={list.name}
            faIcon={list.fa_icon}
          />
        ))}

        <TabLink
          key="Settings"
          isActive={navStore.currentView === 'settings'}
          onClick={navStore.showSettings}
          name="Settings"
          faIcon="cog"
        />
      </ul>
    </div>
  );
}

export default observer(TabNav);
