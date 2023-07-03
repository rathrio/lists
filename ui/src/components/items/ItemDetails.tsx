import React from 'react';
import { observer } from 'mobx-react';
import { observable, action, computed, toJS, makeObservable } from 'mobx';
import * as Mousetrap from 'mousetrap';

import { Item, ItemStatus } from '../../interfaces';
import * as urls from '../../utils/externalItemUrls';
import ItemRating from './ItemRating';
import { publicAssetsUrl } from '../../utils/api';
import RootStore from '../../stores/RootStore';

interface Props {
  store: RootStore;
}

interface FormData extends Partial<Item> {
  [key: string]: any;
}

export function statusTagClassName(itemStatus: ItemStatus): string {
  let className = '';
  switch (itemStatus) {
    case 'doing':
      className = 'is-warning';
      break;
    case 'done':
      className = 'is-success';
      break;
    default:
      className = 'is-light';
      break;
  }
  return className;
}

@observer
class ItemDetails extends React.Component<Props> {
  /**
   * Is used to determine whether to render a form or show a compact,
   * read-only representation.
   */
  @observable
  editing = false;

  @observable
  formData: FormData = {};

  constructor(props: Props) {
    super(props);
    makeObservable(this);

    Mousetrap.bind('e', (e) => {
      if (!this.props.store.itemStore.detailsModalVisible) {
        return;
      }

      e.preventDefault();
      this.toggleEditing();
    });

    Mousetrap.bind('esc', (e) => {
      if (this.isClosed) {
        return;
      }

      e.preventDefault();
      this.close();
    });
  }

  @computed
  get isClosed() {
    return (
      !this.props.store.itemStore.activeItem ||
      !this.props.store.itemStore.detailsModalVisible
    );
  }

  onCancel = (e: React.MouseEvent) => {
    e.preventDefault();
    this.disableEditing();
  };

  @action
  enableEditing = (e: React.MouseEvent) => {
    e.preventDefault();
    if (this.props.store.itemStore.activeItem?.deleted) {
      return;
    }

    this.editing = true;
  };

  @action
  disableEditing = () => {
    this.formData = {};
    this.editing = false;
  };

  @action
  toggleEditing = () => {
    if (this.props.store.itemStore.activeItem?.deleted) {
      return;
    }

    this.editing = !this.editing;
  };

  get hasFormDataChanges() {
    return Object.keys(this.formData).length !== 0;
  }

  @action
  close = () => {
    if (this.hasFormDataChanges) {
      if (!window.confirm('You have unsaved changes. Close this anyways?')) {
        return;
      }
    }

    this.disableEditing();
    this.props.store.itemStore.hideDetailsModal();
  };

  handleFormChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    this.formData[e.target.name] = e.target.value;
  };

  onSave = (e: React.FormEvent) => {
    e.preventDefault();

    if (this.hasFormDataChanges) {
      const item = this.props.store.itemStore.activeItem!;
      this.props.store.itemStore.update(item, toJS(this.formData));
    }

    this.formData = {};
    this.disableEditing();
  };

  onArchiveClick = (e: React.MouseEvent) => {
    e.preventDefault();
    const { store } = this.props;
    const item = store.itemStore.activeItem!;
    const confirmedArchival = store.itemStore.archive(item);

    if (confirmedArchival) {
      this.disableEditing();
    }
  };

  onRestoreClick = (e: React.MouseEvent) => {
    e.preventDefault();
    const { store } = this.props;
    const item = store.itemStore.activeItem!;
    store.itemStore.restore(item);
  };

  onDeleteClick = (e: React.MouseEvent) => {
    e.preventDefault();
    const { store } = this.props;
    const item = store.itemStore.activeItem!;
    store.itemStore.delete(item);
  };

  onStatusTagClick = (e: React.MouseEvent) => {
    e.preventDefault();
    const { store } = this.props;
    const item = store.itemStore.activeItem!;
    store.itemStore.toggleStatus(item);
  };

  render() {
    const { store } = this.props;
    const item = store.itemStore.activeItem;

    // Render nothing if there's no active item. Guard is necessary because
    // this component is always mounted.
    if (!item) {
      return '';
    }

    const statusClass = statusTagClassName(item.status);
    const coverAspectRatio = store.listStore.activeList!.cover_aspect_ratio;

    return (
      <div
        className={`modal item-details-modal ${
          store.itemStore.detailsModalVisible ? 'is-active' : ''
        }`}
      >
        <div onClick={this.close} className="modal-background" />

        <form onSubmit={this.onSave}>
          <div className="modal-card">
            <header className="modal-card-head">
              <span
                className="icon is-medium is-hidden-mobile"
                style={{ marginRight: '5px' }}
              >
                <i className={`fa fa-${item.fa_icon} fa-lg`} />
              </span>

              <p className="modal-card-title">{`${item.name} ${
                item.deleted ? ' (Archived)' : ''
              }`}</p>

              {item.original_name && (
                <code
                  style={{ marginLeft: '0.5em' }}
                  className="is-hidden-touch"
                >
                  {item.original_name}
                </code>
              )}

              <div className="header-actions">
                <span className="external-item-links is-hidden-touch">
                  <a target="blank" href={urls.pirateSearchUrl(item)}>
                    <span className="icon is-medium">
                      <i className="fas fa-magnet fa-lg" />
                    </span>
                  </a>

                  <a target="blank" href={urls.googleSearchUrl(item)}>
                    <span className="icon is-medium">
                      <i className="fab fa-google fa-lg" />
                    </span>
                  </a>

                  <a target="blank" href={urls.youtubeSearchUrl(item)}>
                    <span className="icon is-medium">
                      <i className="fab fa-youtube fa-lg" />
                    </span>
                  </a>

                  <a target="blank" href={urls.bflixSearchUrl(item)}>
                    <span className="icon is-medium">
                      <i className="fas fa-tv fa-lg" />
                    </span>
                  </a>
                </span>
              </div>
            </header>

            <section className="modal-card-body">
              <div className="image-content" style={{ marginBottom: '20px' }}>
                <figure className={`image is-${coverAspectRatio}`}>
                  <img
                    src={publicAssetsUrl(item.image!.url)}
                    alt={item.name}
                    style={{
                      objectFit: 'cover',
                      borderRadius: '5px',
                      maxHeight: 'auto',
                    }}
                  />
                </figure>
              </div>

              {this.editing ? (
                <div className="fields" style={{ marginBottom: '20px' }}>
                  <div className="field">
                    <label className="label is-small">Name</label>

                    <p className="control">
                      <input
                        name="name"
                        defaultValue={item.name}
                        onChange={this.handleFormChange}
                        className="input is-small"
                        type="text"
                        placeholder="Name"
                        required
                      />
                    </p>
                  </div>

                  <div className="field">
                    <label className="label is-small">Description</label>
                    <div className="control">
                      <textarea
                        name="description"
                        rows={5}
                        defaultValue={item.description}
                        onChange={this.handleFormChange}
                        className="textarea is-small"
                        placeholder="Description"
                      />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label is-small">Language</label>
                    <div className="control">
                      <input
                        name="language"
                        className="input is-small"
                        placeholder="en"
                        defaultValue={item.language}
                        onChange={this.handleFormChange}
                        pattern="[a-z]{2}"
                      />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label is-small">Original Name</label>
                    <div className="control">
                      <input
                        name="original_name"
                        className="input is-small"
                        defaultValue={item.original_name}
                        onChange={this.handleFormChange}
                      />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label is-small">Recommended By</label>
                    <div className="control">
                      <input
                        name="recommended_by"
                        className="input is-small"
                        placeholder="Spongebob Squarepants"
                        defaultValue={item.recommended_by}
                        onChange={this.handleFormChange}
                      />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label is-small">Release Date</label>
                    <div className="control">
                      <input
                        name="date"
                        type="date"
                        className="input is-small"
                        placeholder="Release Date"
                        defaultValue={item.date}
                        onChange={this.handleFormChange}
                        required
                      />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label is-small">First Completion</label>
                    <div className="control">
                      <input
                        name="first_done_at"
                        type="date"
                        className="input is-small"
                        placeholder="First Completion"
                        defaultValue={item.first_done_at}
                        onChange={this.handleFormChange}
                      />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label is-small">Tags</label>
                    <div className="control">
                      <input
                        name="tags"
                        className="input is-small"
                        placeholder="e.g. Horror, Fiction"
                        defaultValue={item.tags.join(', ')}
                        onChange={this.handleFormChange}
                      />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label is-small">Image</label>
                    <div className="control">
                      <input
                        name="remote_image_url"
                        type="url"
                        className="input is-small"
                        placeholder="Paste link to new image here"
                        defaultValue={item.remote_image_url}
                        onChange={this.handleFormChange}
                      />
                    </div>
                  </div>
                </div>
              ) : (
                <div className="fields" style={{ marginBottom: '20px' }}>
                  <div className="tags">
                    <span className="tag is-rounded is-small is-light">
                      {item.year}
                    </span>

                    {item.tags.map((tag) => (
                      <span
                        key={tag}
                        className="tag is-rounded is-small is-light"
                      >
                        {tag}
                      </span>
                    ))}

                    <span
                      className={`tag is-rounded is-small ${statusClass} has-pointer`}
                      aria-label="Toggle status"
                      data-balloon-pos="down"
                      onClick={this.onStatusTagClick}
                    >
                      {item.human_status}
                    </span>

                    <span
                      className="item-rating"
                      style={{ marginTop: '-10px', marginLeft: '3px' }}
                    >
                      <ItemRating
                        item={item}
                        onUpdateRating={store.itemStore.updateRating}
                      />
                    </span>
                  </div>

                  <p className="item-description">{item.description}</p>

                  {item.language && (
                    <p className="item-language" style={{ marginTop: '1em' }}>
                      <strong>Language:</strong>{' '}
                      <code>{item.language.toUpperCase()}</code>
                    </p>
                  )}

                  {item.original_name && (
                    <p className="item-original_name">
                      <strong>Original name:</strong>{' '}
                      <code>{item.original_name}</code>
                    </p>
                  )}

                  {item.recommended_by && (
                    <p className="item-recommended_by">
                      <strong>Recommended by:</strong>{' '}
                      <code>{item.recommended_by}</code>
                    </p>
                  )}
                </div>
              )}
            </section>

            {this.editing ? (
              <footer className="modal-card-foot">
                <div className="actions-left">
                  <button
                    type="button"
                    tabIndex={-1}
                    onClick={this.onArchiveClick}
                    className="button is-danger"
                  >
                    <span className="icon">
                      <i className="fa fa-archive" />
                    </span>

                    <span>Archive</span>
                  </button>
                </div>

                <div className="actions-right">
                  {this.hasFormDataChanges && (
                    <button className="button is-primary">
                      <span className="icon">
                        <i className="fa fa-save" />
                      </span>
                      <span>Update</span>
                    </button>
                  )}

                  <button
                    type="button"
                    onClick={this.onCancel}
                    className="button"
                  >
                    Cancel
                  </button>
                </div>
              </footer>
            ) : (
              <footer className="modal-card-foot">
                {item.deleted && (
                  <div className="actions-left">
                    <button
                      type="button"
                      onClick={this.onRestoreClick}
                      className="button is-primary"
                    >
                      <span className="icon">
                        <i className="fa fa-recycle" />
                      </span>

                      <span>Restore</span>
                    </button>

                    <button
                      type="button"
                      onClick={this.onDeleteClick}
                      className="button is-danger"
                    >
                      <span className="icon">
                        <i className="fa fa-trash" />
                      </span>

                      <span>Delete</span>
                    </button>
                  </div>
                )}

                <div className="actions-right">
                  {!item.deleted && (
                    <button
                      type="button"
                      onClick={this.enableEditing}
                      className="button"
                    >
                      <span className="icon">
                        <i className="fa fa-pencil-alt" />
                      </span>
                      <span>Edit</span>
                    </button>
                  )}

                  <button type="button" onClick={this.close} className="button">
                    Close
                  </button>
                </div>
              </footer>
            )}
          </div>
        </form>
      </div>
    );
  }
}

export default ItemDetails;
