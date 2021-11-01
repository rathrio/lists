import { action, observable } from "mobx";
import RootStore from './RootStore';
import { List } from '../interfaces';

type View = 'items' | 'settings';

class NavStore {
  @observable
  currentView: View = 'items';

  private rootStore: RootStore;

  constructor(rootStore: RootStore) {
    this.rootStore = rootStore;
  }

  @action
  showList = (list: List) => {
    this.currentView = 'items';
    this.rootStore.listStore.activateList(list);
  }

  @action
  showSettings = () => {
    this.currentView = 'settings';
  }
}

export default NavStore;
