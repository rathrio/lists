import React from 'react';
import TabNav from './TabNav';
import MainSection from './MainSection';
import RootStore from '../stores/RootStore';

function App() {
  const rootStore = new RootStore();
  (window as any).store = rootStore;

  return (
    <>
      <TabNav store={rootStore} />
      <MainSection store={rootStore} />
    </>
  );
}

export default App;
