import { action, makeObservable, observable } from 'mobx';
import RootStore from './RootStore';
import { List } from '../interfaces';
import slug from '../utils/slug';

type View = 'items' | 'settings';

class NavStore {
  @observable
  currentView: View = 'items';

  private rootStore: RootStore;

  constructor(rootStore: RootStore) {
    makeObservable(this);
    this.rootStore = rootStore;

    window.addEventListener('popstate', (event) => {
      this.resolveFromPathname();
    });
  }

  resolve = () => {
    if (this.resolveFromPathname()) {
      return;
    }

    this.showFirstList();
  };

  showFirstList = () => {
    const lists = this.rootStore.listStore.lists;
    if (!lists.length) {
      return;
    }

    this.showList(lists[0]);
  };

  /**
   * @return whether the state could be successfully resolved from pathname
   */
  resolveFromPathname = (): boolean => {
    const pathname = window.location.pathname.replace('/', '');

    switch (pathname) {
      case '':
        this.showFirstList();
        return true;
      case 'settings':
        this.showSettings(false);
        return true;
      default:
        const list = this.rootStore.listStore.getListBySlug(pathname);
        if (!list) {
          console.error(`Could not resolve list "${pathname}"`);
          return false;
        }
        this.showList(list, false);
        return true;
    }
  };

  @action
  showList = (list: List, pushState = true) => {
    this.currentView = 'items';
    this.rootStore.listStore.activateList(list);
    window.document.title = `Lists - ${list.name}`;

    if (pushState) {
      window.history.pushState(
        { list: list.name },
        list.name,
        slug(list.name)
      );
    }
  };

  @action
  showSettings = (pushState = true) => {
    this.currentView = 'settings';
    window.document.title = `Lists - Settings`;

    if (pushState) {
      window.history.pushState({}, 'Settings', 'settings');
    }
  };
}

export default NavStore;
