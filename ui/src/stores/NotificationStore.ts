import RootStore from './RootStore';
import { action, computed, observable } from 'mobx';

const EMPTY_NOTIFICATION = { message: '', notificationClass: '' };

class NotificationStore {
  private rootStore: RootStore;
  private currentTimeouts: any[] = [];

  @observable
  notification = EMPTY_NOTIFICATION;

  constructor(rootStore: RootStore) {
    this.rootStore = rootStore;
  }

  @computed
  get hasNotification() {
    return !!this.notification.message;
  }

  @action
  clearNotification = () => {
    this.clearTimeouts();
    this.notification = EMPTY_NOTIFICATION;
  };

  @action
  showNotification = (
    message: string,
    notificationClass = 'is-success',
    clearAfter = 3500
  ) => {
    this.clearTimeouts();
    this.notification = { message, notificationClass };
    this.currentTimeouts.push(
      setTimeout(() => {
        this.notification.notificationClass += ' fade-out';
        this.currentTimeouts.push(
          setTimeout(() => (this.notification = EMPTY_NOTIFICATION), 400)
        );
      }, clearAfter)
    );
  };

  private clearTimeouts = () => {
    this.currentTimeouts.forEach((timeout) => clearTimeout(timeout));
    this.currentTimeouts = [];
  };
}

export default NotificationStore;
