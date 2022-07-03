import React from 'react';
import TabNav from './TabNav';
import MainSection from './MainSection';
import Notification from './Notification';
import RootStore from '../stores/RootStore';
import Login from './Login';
import { observer } from 'mobx-react';

const rootStore = new RootStore();
(window as any).store = rootStore;

function App() {
  const listStore = rootStore.listStore;
  if (!listStore.initialized) {
    return <></>;
  }

  const { sessionStore, notificationStore } = rootStore;
  if (!sessionStore.isLoggedIn) {
    return (
      <>
        <Login store={sessionStore} />
        <Notification store={notificationStore} />
      </>
    );
  }

  return (
    <>
      <TabNav store={rootStore} />
      <MainSection store={rootStore} />
      <Notification store={notificationStore} />
    </>
  );
}

export default observer(App);
