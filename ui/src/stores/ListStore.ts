import { action, observable } from 'mobx';
import Mousetrap from 'mousetrap';
import { List } from '../interfaces';
import API from '../utils/api';
import RootStore from './RootStore';

const ARCHIVE: List = {
  id: -1,
  name: 'Archive',
  fa_icon: 'archive',
  description: 'Virtual List for display purposes'
}

class ListStore {
  readonly lists = observable<List>([]);
  private rootStore: RootStore;

  @observable
  activeList?: List;

  constructor(rootStore: RootStore) {
    this.rootStore = rootStore;

    API.get('/lists').then((response) => {
      this.lists.replace(response.data.concat([ARCHIVE]));
      this.updateShortcuts();

      if (this.lists.length) {
        this.activeList = this.lists[0];
      }
    });
  }

  @action
  activateList(list: List) {
    this.activeList = list;
  }

  private updateShortcuts = () => {
    this.lists.forEach((list, index) => {
      Mousetrap.bind((index + 1).toString(10), (e) => {
        e.preventDefault();
        this.activateList(list);
      })
    })
  };
}

export default ListStore;
