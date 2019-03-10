import React from 'react';
import { observer } from 'mobx-react';
import { observable, action, computed } from 'mobx';
import * as Mousetrap from 'mousetrap';

import ItemStore from '../stores/ItemStore';
import { Item } from '..';
import * as urls from '../../utils/external_item_urls';
import ItemRating from './ItemRating';
import NoteBoxes from './NoteBoxes';

interface Props {
  store: ItemStore;
}

interface FormData extends Partial<Item> {
  [key: string]: any;
}

@observer
class ItemDetails extends React.Component<Props> {
  /**
   * Is used to determine whether to render a form or show a compact,
   * read-only representation.
   */
  @observable
  editing = false;

  formData: FormData = {};

  constructor(props: Props) {
    super(props);

    Mousetrap.bind('e', (e) => {
      if (!this.props.store.detailsModalVisible) {
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
      !this.props.store.activeItem || !this.props.store.detailsModalVisible
    );
  }

  onCancel = (e: React.MouseEvent) => {
    e.preventDefault();
    this.disableEditing();
  };

  @action
  enableEditing = () => {
    this.editing = true;
  };

  @action
  disableEditing = () => {
    this.formData = {};
    this.editing = false;
  };

  @action
  toggleEditing = () => {
    this.editing = !this.editing;
  };

  get hasFormDataChanges() {
    return Object.keys(this.formData).length !== 0;
  }

  @action
  close = () => {
    if (this.hasFormDataChanges) {
      if (!confirm('You have unsaved changes. Close this anyways?')) {
        return;
      }
    }

    this.disableEditing();
    this.props.store.hideDetailsModal();
  };

  handleFormChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    this.formData[e.target.name] = e.target.value;
  };

  onSave = (e: React.FormEvent) => {
    e.preventDefault();

    if (this.hasFormDataChanges) {
      const item = this.props.store.activeItem!;
      this.props.store.update(item, this.formData);
    }

    this.formData = {};
    this.disableEditing();
  };

  onArchiveClick = (e: React.MouseEvent) => {
    e.preventDefault();
    const { store } = this.props;
    const item = store.activeItem!;
    store.archive(item);
  };

  onRestoreClick = (e: React.MouseEvent) => {
    e.preventDefault();
    const { store } = this.props;
    const item = store.activeItem!;
    store.restore(item);
  };

  onStatusTagClick = (e: React.MouseEvent) => {
    e.preventDefault();
    const { store } = this.props;
    const item = store.activeItem!;
    store.toggleStatus(item);
  };

  render() {
    const { store } = this.props;
    const item = store.activeItem;

    // Render nothing if there's no active item. Guard is necessary because
    // this component is always mounted.
    if (!item) {
      return '';
    }

    let statusTagClassName = '';
    switch (item.status) {
      case 'doing':
        statusTagClassName = 'is-warning';
        break;
      case 'done':
        statusTagClassName = 'is-success';
      default:
        break;
    }

    return (
      <div
        className={`modal item-details-modal ${
          store.detailsModalVisible ? 'is-active' : ''
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

              <span className="external-item-links hidden is-hidden-touch">
                <a target="blank" href={urls.pirateSearchUrl(item)}>
                  <span className="icon is-medium">
                    <i className="fa fa-magnet fa-lg" />
                  </span>
                </a>

                <a target="blank" href={urls.googleSearchUrl(item)}>
                  <span className="icon is-medium">
                    <i className="fa fa-google fa-lg" />
                  </span>
                </a>

                <a target="blank" href={urls.youtubeSearchUrl(item)}>
                  <span className="icon is-medium">
                    <i className="fa fa-youtube-play fa-lg" />
                  </span>
                </a>

                <a target="blank" href={urls.netflixSearchUrl(item)}>
                  <span className="icon is-medium">
                    <i className="fa fa-tv fa-lg" />
                  </span>
                </a>
              </span>

              {!this.editing && (
                <span
                  className="icon is-medium edit-item-pencil"
                  onClick={this.enableEditing}
                >
                  <i className="fa fa-pencil fa-lg" />
                </span>
              )}
            </header>

            <section className="modal-card-body">
              <div className="image-content">
                <figure className="image is-2by3">
                  <img
                    src={item.image!.url}
                    alt={item.name}
                    style={{
                      objectFit: 'cover',
                      borderRadius: '5px',
                      maxHeight: 'auto'
                    }}
                  />
                </figure>
              </div>

              {this.editing ? (
                <div className="fields">
                  <div className="field">
                    <label className="label is-small">Name</label>
                    <p className="control">
                      <input
                        name="name"
                        defaultValue={item.name}
                        onChange={this.handleFormChange}
                        className="input"
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
                        rows={7}
                        defaultValue={item.description}
                        onChange={this.handleFormChange}
                        className="textarea"
                        placeholder="Description"
                        autoFocus
                      />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label is-small">Release Date</label>
                    <div className="control">
                      <input
                        name="date"
                        type="date"
                        className="input"
                        placeholder="Release Date"
                        defaultValue={item.date}
                        onChange={this.handleFormChange}
                        required
                      />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label is-small">Image</label>
                    <div className="control has-icon">
                      <input
                        name="remote_image_url"
                        type="url"
                        className="input"
                        placeholder="Paste link to new image here"
                        defaultValue={item.remote_image_url}
                        onChange={this.handleFormChange}
                      />

                      <span className="icon">
                        <i className="fa fa-external-link" />
                      </span>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="fields">
                  <div className="tags">
                    <span className="tag is-rounded is-small">{item.year}</span>

                    {item.tags.map((tag) => (
                      <span key={tag} className="tag is-rounded is-small">
                        {tag}
                      </span>
                    ))}

                    <span
                      className={`tag is-rounded is-small ${statusTagClassName} has-pointer`}
                      data-balloon="Toggle status"
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
                        onUpdateRating={store.updateRating}
                      />
                    </span>

                    {item.deleted ? (
                      <a
                        href="#"
                        onClick={this.onRestoreClick}
                        style={{ marginTop: '-10px', marginLeft: 'auto' }}
                        data-balloon="Restore"
                        data-balloon-pos="down"
                      >
                        <span className="icon is-medium">
                          <i className="fa fa-recycle fa-lg" />
                        </span>
                      </a>
                    ) : (
                      <a
                        href="#"
                        onClick={this.onArchiveClick}
                        style={{ marginTop: '-10px', marginLeft: 'auto' }}
                        data-balloon="Archive"
                        data-balloon-pos="down"
                      >
                        <span className="icon is-medium">
                          <i className="fa fa-archive fa-lg" />
                        </span>
                      </a>
                    )}
                  </div>

                  <p className="item-description">{item.description}</p>

                  {/* <NoteBoxes item={item} store={store} style={{ marginTop: '1.5rem' }}/> */}
                </div>
              )}
            </section>

            {this.editing ? (
              <footer className="modal-card-foot">
                <button className="button is-primary">Update</button>
                <button onClick={this.onCancel} className="button">
                  Cancel
                </button>
              </footer>
            ) : (
              <footer className="modal-card-foot">
                <button onClick={this.close} className="button">
                  Close
                </button>
              </footer>
            )}
          </div>
        </form>
      </div>
    );
  }
}

export default ItemDetails;
