import ItemStore from './ItemStore';
import ListStore from './ListStore';
import NavStore from './NavStore';

class RootStore {
  public readonly navStore: NavStore;
  public readonly listStore: ListStore;
  public readonly itemStore: ItemStore;

  constructor() {
    this.navStore = new NavStore(this);
    this.listStore = new ListStore(this);
    this.itemStore = new ItemStore(this);
  }
}

export default RootStore;
