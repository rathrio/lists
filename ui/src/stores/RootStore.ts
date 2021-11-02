import ItemStore from './ItemStore';
import ListStore from './ListStore';
import NavStore from './NavStore';
import SessionStore from './SessionStore';

class RootStore {
  public readonly sessionStore: SessionStore;
  public readonly navStore: NavStore;
  public readonly listStore: ListStore;
  public readonly itemStore: ItemStore;

  constructor() {
    this.sessionStore = new SessionStore(this);
    this.navStore = new NavStore(this);
    this.listStore = new ListStore(this);
    this.itemStore = new ItemStore(this);
  }
}

export default RootStore;
