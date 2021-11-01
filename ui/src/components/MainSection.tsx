import Items from './Items';
import RootStore from '../stores/RootStore';
import { observer } from 'mobx-react';
import Settings from './Settings';

function MainSection(props: { store: RootStore }) {
  const currentView = props.store.navStore.currentView;

  return (
    <section className="section main-section">
      <div className="container">
        {currentView === 'items' && <Items store={props.store}/>}
        {currentView === 'settings' && <Settings store={props.store}/>}
      </div>
    </section>
  );
}

export default observer(MainSection);
