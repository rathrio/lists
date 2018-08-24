import React, { Fragment } from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';
import ItemRating from './ItemRating';

interface Props {
  store: ItemStore;
}

interface State {
  editing: boolean;
}

@observer
class ItemDetails extends React.Component<Props, State> {
  readonly state: State = {
    editing: false
  };

  onCancel = (e: any) => {
    e.preventDefault();
    this.disableEditing();
  };

  enableEditing = () => {
    this.setState({ editing: true });
  };

  disableEditing = () => {
    this.setState({ editing: false });
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
        <div onClick={store.hideDetailsModal} className="modal-background" />

        <form>
          <div className="modal-card">
            <header className="modal-card-head">
              <p className="modal-card-title">{item.name}</p>

              <span className="external-item-links hidden">
                <a target="blank" href={''}>
                  <span className="icon is-medium">
                    <i className="fa fa-magnet fa-lg" />
                  </span>
                </a>

                <a target="blank" href={''}>
                  <span className="icon is-medium">
                    <i className="fa fa-google fa-lg" />
                  </span>
                </a>

                <a target="blank" href={''}>
                  <span className="icon is-medium">
                    <i className="fa fa-youtube-play fa-lg" />
                  </span>
                </a>

                <a target="blank" href={''}>
                  <span className="icon is-medium">
                    <i className="fa fa-tv fa-lg" />
                  </span>
                </a>
              </span>

              {!this.state.editing && (
                <span
                  className="icon is-medium edit-item-pencil hidden"
                  onClick={this.enableEditing}
                >
                  <i className="fa fa-pencil fa-lg" />
                </span>
              )}
            </header>

            <section className="modal-card-body">
              <div>
                <figure className="image is-2by3">
                  <img
                    src={item.image!.url}
                    alt={item.name}
                    style={{ objectFit: 'cover', borderRadius: '5px', maxHeight: 'auto' }}
                  />
                </figure>
              </div>

              <div>
                <div className="tags">
                  <span className="tag is-rounded is-medium">{item.year}</span>
                  {item.tags.map((tag) => (
                    <span key={tag} className="tag is-rounded is-medium">{tag}</span>
                  ))}
                </div>

                <p>{item.description}</p>
              </div>
            </section>

            {this.state.editing && (
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
