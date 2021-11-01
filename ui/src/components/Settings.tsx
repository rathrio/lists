import { observer } from 'mobx-react';
import RootStore from '../stores/RootStore';

// TODO: actual settings
function Settings(props: { store: RootStore }) {
  return (
    <aside className="menu">
      <p className="menu-label">General</p>
      <ul className="menu-list">
        <li>
          <a className="is-active">Lists</a>
        </li>
      </ul>

      <p className="menu-label">Profile</p>
      <ul className="menu-list">
        <li>
          <a>Change Password</a>
        </li>
        <li>
          <a>Sign Out</a>
        </li>
      </ul>
    </aside>
  );
}

export default observer(Settings);
