import { useState } from 'react';
import SessionStore from '../stores/SessionStore';

function Login(props: { store: SessionStore }) {
  const store = props.store;

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const onSubmit = (e: any) => {
    e.preventDefault();
    store.login(email, password);
  }

  return (
    <div className="section">
      <div className="container">
        <div className="columns">
          <div className="column is-half is-offset-one-quarter sign-in">
            <form onSubmit={onSubmit}>
              <div className="field">
                <p className="control has-icons-left">
                  <input
                    type="email"
                    className="input"
                    placeholder="Email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                  />
                  <span className="icon is-left is-small">
                    <i className="fa fa-envelope" />
                  </span>
                </p>
              </div>

              <div className="field">
                <p className="control has-icons-left">
                  <input
                    type="password"
                    className="input"
                    placeholder="Password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                  />
                  <span className="icon is-left is-small">
                    <i className="fa fa-lock" />
                  </span>
                </p>
              </div>

              <div className="field">
                <p className="control">
                  <input
                    type="submit"
                    name="commit"
                    value="Login"
                    className="button is-success"
                    data-disable-with="Login"
                  />
                </p>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Login;
