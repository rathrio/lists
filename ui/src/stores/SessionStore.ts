import { action, observable } from 'mobx';
import RootStore from './RootStore';
import API from '../utils/api';

class SessionStore {
  private rootStore: RootStore;

  @observable
  isLoggedIn: boolean = false;

  constructor(rootStore: RootStore) {
    this.rootStore = rootStore;
  }

  @action
  setLoggedIn = (loggedIn: boolean) => {
    this.isLoggedIn = loggedIn;
  };

  @action
  login = (email: string, password: string) => {
    API.post('/sign_in', { email: email, password: password }).then(
      (response) => {
        this.setLoggedIn(true)
        this.rootStore.listStore.init();
      },
      (error) => this.setLoggedIn(false) // TODO feedback
    );
  };

  @action
  logout = () => {
    API.post('/sign_out').then((response) => this.setLoggedIn(false));
  };
}

export default SessionStore;
