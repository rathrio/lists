import { useEffect, useState } from 'react';
import RootStore from '../../stores/RootStore';
import { publicAssetsUrl } from '../../utils/api';

function ApiToken(props: { store: RootStore }) {
  const { sessionStore, notificationStore } = props.store;
  const [active, setActive] = useState(false);
  const [token, setToken] = useState('');

  useEffect(() => {
    sessionStore.hasApiToken().then(setActive);
  }, [sessionStore]);

  const generate = () => {
    if (
      active &&
      !window.confirm(
        'This replaces your current token. Clients using it will lose access.'
      )
    ) {
      return;
    }

    sessionStore.generateApiToken().then(
      (newToken) => {
        setToken(newToken);
        setActive(true);
      },
      () =>
        notificationStore.showNotification(
          'Token generation failed',
          'is-danger'
        )
    );
  };

  const revoke = () => {
    if (!window.confirm('Clients using this token will lose access.')) {
      return;
    }

    sessionStore.revokeApiToken().then(() => {
      setToken('');
      setActive(false);
      notificationStore.showNotification('API token revoked');
    });
  };

  const copy = () => {
    navigator.clipboard
      .writeText(token)
      .then(() => notificationStore.showNotification('Copied to clipboard'));
  };

  return (
    <>
      <h1 className="subtitle is-4">API Token</h1>

      <p className="mb-3">
        Gives MCP clients like Claude Desktop read access to your library via{' '}
        <code>{publicAssetsUrl('/mcp')}</code>.
      </p>

      {token && (
        <div className="field">
          <div className="field has-addons mb-0">
            <p className="control is-expanded has-icons-left">
              <input
                type="text"
                className="input"
                value={token}
                readOnly
                onFocus={(e) => e.target.select()}
              />
              <span className="icon is-left is-small">
                <i className="fa fa-key" />
              </span>
            </p>
            <p className="control">
              <button className="button" onClick={copy}>
                Copy
              </button>
            </p>
          </div>
          <p className="help">Copy it now, it won't be shown again.</p>
        </div>
      )}

      {active && !token && (
        <div className="field">
          <p className="control has-icons-left">
            <input
              type="text"
              className="input"
              value="lists_••••••••••••••••"
              disabled
            />
            <span className="icon is-left is-small">
              <i className="fa fa-key" />
            </span>
          </p>
          <p className="help">
            You have an active token. It can't be shown again, regenerate it if
            you lost it.
          </p>
        </div>
      )}

      <div className="field is-grouped">
        <p className="control">
          <button className="button is-success" onClick={generate}>
            {active ? 'Regenerate' : 'Generate'}
          </button>
        </p>
        {active && (
          <p className="control">
            <button className="button is-danger is-outlined" onClick={revoke}>
              Revoke
            </button>
          </p>
        )}
      </div>
    </>
  );
}

export default ApiToken;
