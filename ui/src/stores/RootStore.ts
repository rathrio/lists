import ItemStore from './ItemStore';
import ListStore from './ListStore';

class RootStore {
  public readonly listStore: ListStore;
  public readonly itemStore: ItemStore;

  constructor() {
    this.listStore = new ListStore(this);
    this.itemStore = new ItemStore(this);
  }
}

export default RootStore;
