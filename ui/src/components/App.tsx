import React from 'react';
import TabNav from './TabNav';
import MainSection from './MainSection';
import RootStore from '../stores/RootStore';
import Login from './Login';
import { observer } from 'mobx-react';

const rootStore = new RootStore();
(window as any).store = rootStore;

function App() {
  const sessionStore = rootStore.sessionStore;

  if (!sessionStore.isLoggedIn) {
    return <Login store={sessionStore} />;
  }

  return (
    <>
      <TabNav store={rootStore} />
      <MainSection store={rootStore} />
    </>
  );
}

export default observer(App);
