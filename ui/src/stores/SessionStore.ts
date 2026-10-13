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
      (_response) => {
        this.setLoggedIn(true);
        this.rootStore.listStore.init();
      },
      (_error) => {
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
    API.post('/sign_out').then((_response) => this.setLoggedIn(false));
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

  hasApiToken = (): Promise<boolean> => {
    return API.get('/api_token').then((response) => response.data.active);
  };

  // Replaces any previous token. The plaintext token is only ever returned
  // here, the API just keeps a digest.
  generateApiToken = (): Promise<string> => {
    return API.post('/api_token').then((response) => response.data.token);
  };

  revokeApiToken = (): Promise<unknown> => {
    return API.delete('/api_token');
  };
}

export default SessionStore;
