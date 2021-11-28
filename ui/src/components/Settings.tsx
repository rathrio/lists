import { observer } from 'mobx-react';
import RootStore from '../stores/RootStore';
import ChangePassword from './ChangePassword';

function Settings(props: { store: RootStore }) {
  const sessionStore = props.store.sessionStore;
  return (
    <>
      <div className="columns">
        <div className="column is-half is-offset-one-quarter sign-in">
          <ChangePassword store={props.store} />
          <hr />
          <div className="is-flex">
            <button
              className="button is-info"
              onClick={() => sessionStore.logout()}
            >
              Sign out
            </button>
          </div>
        </div>
      </div>
    </>
  );
}

export default observer(Settings);
