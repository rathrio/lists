import { observer } from 'mobx-react';
import NotificationStore from '../../stores/NotificationStore';

function Notification(props: { store: NotificationStore }) {
  const { store } = props;
  if (!store.hasNotification) {
    return null;
  }

  const notification = store.notification;
  return (
    <div
      className={`flash-notification notification ${notification.notificationClass}`}
    >
      <button onClick={store.clearNotification} className="delete" />
      {notification.message}
    </div>
  );
}

export default observer(Notification);
