import { observer } from 'mobx-react';
import RootStore from '../stores/RootStore';

// TODO: actual settings
// TODO: password reset
// TODO: options to hide default lists
function Settings(props: { store: RootStore }) {
  const sessionStore = props.store.sessionStore;
  return (
    <button className="button is-info" onClick={() => sessionStore.logout()}>Sign out</button>
  );
}

export default observer(Settings);
