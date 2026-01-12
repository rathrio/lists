import { action, computed, makeObservable, observable } from 'mobx';
import Mousetrap from 'mousetrap';
import { List } from '../interfaces';
import API from '../utils/api';
import RootStore from './RootStore';
import slug from '../utils/slug';

const JOURNAL: List = {
  id: -2,
  name: 'Journal',
  fa_icon: 'calendar',
  description: 'Completed items in chronological order',
  cover_aspect_ratio: '2by3',
};

const ARCHIVE: List = {
  id: -1,
  name: 'Archive',
  fa_icon: 'archive',
  description: 'Virtual List for display purposes',
  cover_aspect_ratio: '2by3',
};

class ListStore {
  readonly lists = observable<List>([]);
  private rootStore: RootStore;

  @observable
  activeList?: List;

  @observable
  initialized = false;

  constructor(rootStore: RootStore) {
    makeObservable(this);
    this.rootStore = rootStore;

    this.init();
  }

  init = () => {
    API.get('/lists')
      .then(
        action((response) => {
          this.rootStore.sessionStore.setLoggedIn(true);
          this.lists.replace(response.data.concat([JOURNAL, ARCHIVE]));
          this.updateShortcuts();
          this.rootStore.navStore.resolve();
        }),
        action((error) => {
          if (error.response.status === 401) {
            this.rootStore.sessionStore.setLoggedIn(false);
          }
        })
      )
      .finally(
        action(() => {
          this.initialized = true;
        })
      );
  };

  @computed
  get listsBySlug(): Map<String, List> {
    const map = new Map();
    this.lists.forEach((list) => {
      map.set(slug(list.name), list);
    });

    return map;
  }

  getListBySlug = (slug: string): List | undefined => {
    return this.listsBySlug.get(slug);
  };

  @action
  activateList(list: List) {
    this.activeList = list;
  }

  private updateShortcuts = () => {
    this.lists.forEach((list, index) => {
      Mousetrap.bind((index + 1).toString(10), (e) => {
        e.preventDefault();
        this.rootStore.navStore.showList(list);
      });
    });

    Mousetrap.bind('g j', (e) => {
      e.preventDefault();
      this.rootStore.navStore.showList(JOURNAL);
    });

    Mousetrap.bind('g a', (e) => {
      e.preventDefault();
      this.rootStore.navStore.showList(ARCHIVE);
    });

    Mousetrap.bind(['g s', (this.lists.length + 1).toString(10)], (e) => {
      e.preventDefault();
      this.rootStore.navStore.showSettings();
    });

    // TODO: move me somewhere more appropriate
    Mousetrap.bind('b', (e) => {
      e.preventDefault();
      document.body.classList.toggle('dark');
    });
  };
}

export default ListStore;
export { JOURNAL };
