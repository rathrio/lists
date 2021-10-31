import { observer } from 'mobx-react';
import RootStore from '../stores/RootStore';

function TabNav(props: { store: RootStore }) {
  const listStore = props.store.listStore;
  const lists = listStore.lists;
  const activeList = listStore.activeList;

  return (
    <div className="tabs is-medium is-fullwidth topnav-tabs">
      <ul>
        {lists.map((list) => (
          <li
            key={list.name}
            className={list.id === activeList?.id ? 'is-active' : ''}
          >
            <a onClick={() => listStore.activateList(list)}>
              <span className="icon">
                <i className={`fa fa-${list.fa_icon}`}></i>
              </span>
              <span>{list.name}</span>
            </a>
          </li>
        ))}

        {/*<li*/}
        {/*  className={listStore.isShowingArchived ? 'is-active' : ''}*/}
        {/*>*/}
        {/*  <a onClick={() => listStore.showArchived}>*/}
        {/*      <span className="icon">*/}
        {/*        <i className={`fa fa-${list.fa_icon}`}></i>*/}
        {/*      </span>*/}
        {/*    <span>{list.name}</span>*/}
        {/*  </a>*/}
        {/*</li>*/}

        {/*<li className="is-active">*/}
        {/*  <a data-shortcut="1" href="/items?list_ids=1">*/}
        {/*    <span className="icon">*/}
        {/*      <i className="fa fa-film"></i>*/}
        {/*    </span>*/}
        {/*    <span>Movies</span>*/}
        {/*  </a>*/}
        {/*</li>*/}

        {/*<li className="">*/}
        {/*  <a data-shortcut="2" href="/items?list_ids=4">*/}
        {/*    <span className="icon">*/}
        {/*      <i className="fa fa-gamepad"></i>*/}
        {/*    </span>*/}
        {/*    <span>Games</span>*/}
        {/*  </a>*/}
        {/*</li>*/}

        {/*<li className="">*/}
        {/*  <a data-shortcut="3" href="/items?list_ids=49">*/}
        {/*    <span className="icon">*/}
        {/*      <i className="fa fa-book"></i>*/}
        {/*    </span>*/}
        {/*    <span>Books</span>*/}
        {/*  </a>*/}
        {/*</li>*/}

        {/*<li className="">*/}
        {/*  <a data-shortcut="4" href="/items?list_ids=2">*/}
        {/*    <span className="icon">*/}
        {/*      <i className="fa fa-television"></i>*/}
        {/*    </span>*/}
        {/*    <span>TV Shows</span>*/}
        {/*  </a>*/}
        {/*</li>*/}

        {/*<li className="">*/}
        {/*  <a href="/items?archived=true">*/}
        {/*    <span className="icon">*/}
        {/*      <i className="fa fa-archive"></i>*/}
        {/*    </span>*/}
        {/*    <span>Archive</span>*/}
        {/*  </a>*/}
        {/*</li>*/}

        {/*<li>*/}
        {/*  <a href="/lists">*/}
        {/*    <span className="icon">*/}
        {/*      <i className="fa fa-cog"></i>*/}
        {/*    </span>*/}
        {/*    <span>Settings</span>*/}
        {/*  </a>*/}
        {/*</li>*/}
      </ul>
    </div>
  );
}

export default observer(TabNav);
