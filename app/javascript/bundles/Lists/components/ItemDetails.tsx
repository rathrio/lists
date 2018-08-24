import React from 'react';
import { observer } from 'mobx-react';
import { observable, action } from 'mobx';
import * as Mousetrap from 'mousetrap';

import ItemStore from '../stores/ItemStore';
import { Item } from '..';
import * as urls from '../../utils/external_item_urls';
import ItemRating from './ItemRating';

interface Props {
  store: ItemStore;
}

interface FormData extends Partial<Item> {
  [key: string]: any;
}

@observer
class ItemDetails extends React.Component<Props> {
  @observable
  editing = false;

  formData: FormData = {};

  constructor(props: Props) {
    super(props);

    const store = props.store;

    Mousetrap.bind('e', (e) => {
      e.preventDefault();
      this.toggleEditing();
    });

    Mousetrap.bind('esc', (e) => {
      e.preventDefault();
      this.close();
    });

    Mousetrap.bind('space', (e) => {
      if (!store.activeItem || !store.detailsModalVisible) {
        return;
      }

      e.preventDefault();
      store.onItemToggle(store.activeItem);
    });
  }

  onCancel = (e: any) => {
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

  handleFormChange = (e: any) => {
    this.formData[e.target.name] = e.target.value;
  };

  onSave = (e: any) => {
    e.preventDefault();

    if (this.hasFormDataChanges) {
      const item = this.props.store.activeItem!;
      this.props.store.update(item, this.formData);
    }

    this.formData = {};
    this.disableEditing();
  };

  render() {
    const { store } = this.props;
    const item = store.activeItem;

    if (!item) {
      return '';
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
              <p className="modal-card-title">{item.name}</p>

              <span className="external-item-links hidden">
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

                <div className={`item-rating ${item.rating ? '' : 'hidden'}`} style={{ marginTop: '3px' }}>
                  <ItemRating
                    item={item}
                    onUpdateRating={store.onItemUpdateRating}
                  />
                </div>
              </div>

              {this.editing ? (
                <div>
                  <div className="field">
                    <label className="label">Name</label>
                    <p className="control">
                      <input
                        name="name"
                        defaultValue={item.name}
                        onChange={this.handleFormChange}
                        className="input"
                        type="text"
                        placeholder="Name"
                        required
                        autoFocus
                      />
                    </p>
                  </div>

                  <div className="field">
                    <label className="label">Description</label>
                    <div className="control">
                      <textarea
                        name="description"
                        defaultValue={item.description}
                        onChange={this.handleFormChange}
                        className="textarea"
                        placeholder="Description"
                      />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label">Release Date</label>
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
                </div>
              ) : (
                <div>
                  <div className="tags">
                    <span className="tag is-rounded is-small">{item.year}</span>

                    {item.tags.map((tag) => (
                      <span key={tag} className="tag is-rounded is-small">
                        {tag}
                      </span>
                    ))}

                    {item.status !== 'todo' && (
                      <span
                        className={`tag is-rounded is-small is-${
                          item.status === 'doing' ? 'warning' : 'success'
                        }`}
                      >
                        {item.human_status}
                      </span>
                    )}
                  </div>

                  <p>{item.description}</p>
                </div>
              )}
            </section>

            {this.editing && (
              <footer className="modal-card-foot">
                <button className="button is-primary">Update</button>
                <button onClick={this.onCancel} className="button">
                  Cancel
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
