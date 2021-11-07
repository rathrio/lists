import { action, observable } from 'mobx';
import Mousetrap from 'mousetrap';
import { List } from '../interfaces';
import API from '../utils/api';
import RootStore from './RootStore';

const ARCHIVE: List = {
  id: -1,
  name: 'Archive',
  fa_icon: 'archive',
  description: 'Virtual List for display purposes',
};

class ListStore {
  readonly lists = observable<List>([]);
  private rootStore: RootStore;

  @observable
  activeList?: List;

  @observable
  initialized = false;

  constructor(rootStore: RootStore) {
    this.rootStore = rootStore;

    this.init();
  }

  init = () => {
    API.get('/lists').then(
      action((response) => {
        this.rootStore.sessionStore.setLoggedIn(true);
        this.lists.replace(response.data.concat([ARCHIVE]));
        this.updateShortcuts();

        if (this.lists.length) {
          this.activeList = this.lists[0];
          this.rootStore.navStore.showList(this.activeList);
        }
      }),
      action((error) => {
        if (error.response.status === 401) {
          this.rootStore.sessionStore.setLoggedIn(false);
        }
      })
    ).finally(() => {
      this.initialized = true;
    });
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

    Mousetrap.bind('g a', (e) => {
      e.preventDefault();
      this.rootStore.navStore.showList(ARCHIVE);
    });
  };
}

export default ListStore;
