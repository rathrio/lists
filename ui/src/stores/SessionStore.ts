import { action, makeObservable, observable } from 'mobx';
import RootStore from './RootStore';
import API from '../utils/api';

class SessionStore {
  private rootStore: RootStore;

  @observable
  isLoggedIn: boolean = false;

  constructor(rootStore: RootStore) {
    makeObservable(this);
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
        this.setLoggedIn(true);
        this.rootStore.listStore.init();
      },
      (error) => {
        this.setLoggedIn(false);
        this.rootStore.notificationStore.showNotification(
          'Invalid credentials',
          'is-danger'
        );
      }
    );
  };

  @action
  logout = () => {
    API.post('/sign_out').then((response) => this.setLoggedIn(false));
  };

  updatePassword = (
    currentPassword: string,
    newPassword: string,
    newPasswordConfirmation: string
  ): Promise<any> => {
    return API.put('/profiles', {
      current_password: currentPassword,
      new_password: newPassword,
      new_password_confirmation: newPasswordConfirmation,
    });
  };
}

export default SessionStore;
