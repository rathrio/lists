import { useState } from 'react';
import SessionStore from '../../stores/SessionStore';

function Login(props: { store: SessionStore }) {
  const store = props.store;

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const onSubmit = (e: any) => {
    e.preventDefault();
    store.login(email, password);
  };

  return (
    <>
      <div className="section">
        <nav className="level" style={{ marginBottom: '3rem' }}>
          <div className="level-item has-text-centered">
            <div
              style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}
            >
              <span className="icon is-left is-large">
                <i className="fa fa-2x fa-list" style={{ fontSize: '4rem' }} />
              </span>
            </div>
          </div>
        </nav>
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
                    />
                  </p>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default Login;
