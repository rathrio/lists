import { useState } from 'react';
import SessionStore from '../stores/SessionStore';

function ChangePassword(props: { store: SessionStore }) {
  const store = props.store;

  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [newPasswordConfirmation, setNewPasswordConfirmation] = useState('');
  const [updateFailed, setUpdateFailed] = useState(false);

  const clearForm = () => {
    setCurrentPassword('');
    setNewPassword('');
    setNewPasswordConfirmation('');
  };

  const onSubmit = (e: any) => {
    e.preventDefault();
    store
      .updatePassword(currentPassword, newPassword, newPasswordConfirmation)
      .then(
        () => {
          setUpdateFailed(false);
          clearForm();
        },
        () => {
          setUpdateFailed(true);
        }
      );
  };

  const submitButtonClass = updateFailed ? 'is-danger' : 'is-success';

  const disabled =
    !currentPassword.length ||
    !newPassword.length ||
    !newPasswordConfirmation.length ||
    newPassword !== newPasswordConfirmation;

  return (
    <>
      <h1 className="subtitle is-4">Change Password</h1>

      <form onSubmit={onSubmit}>
        <div className="field">
          <p className="control has-icons-left">
            <input
              type="password"
              className="input"
              placeholder="Current Password"
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              autoComplete="off"
            />
            <span className="icon is-left is-small">
              <i className="fa fa-lock" />
            </span>
          </p>
        </div>

        <div className="field">
          <p className="control has-icons-left">
            <input
              type="password"
              className="input"
              placeholder="New Password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              autoComplete="off"
            />
            <span className="icon is-left is-small">
              <i className="fa fa-lock" />
            </span>
          </p>
        </div>

        <div className="field">
          <p className="control has-icons-left">
            <input
              type="password"
              className="input"
              placeholder="New Password Confirmation"
              value={newPasswordConfirmation}
              onChange={(e) => setNewPasswordConfirmation(e.target.value)}
              autoComplete="off"
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
              value="Update"
              className={`button ${submitButtonClass}`}
              disabled={disabled}
            />
          </p>
        </div>
      </form>
    </>
  );
}

export default ChangePassword;
