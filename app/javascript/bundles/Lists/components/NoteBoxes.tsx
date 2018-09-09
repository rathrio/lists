import React, { CSSProperties } from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';
import { Item } from '..';

interface Props {
  item: Item;
  store: ItemStore;
  style?: CSSProperties;
}

@observer
class NoteBoxes extends React.Component<Props> {
  render() {
    const { item, store, style } = this.props;

    return (
      <div className="note-boxes" style={style}>
        {item.notes.map((note) => (
          <article className="note-box" key={`note-${note.id}`}>
            <div className="note-header">
              {new Date(note.created_at).toLocaleDateString('en-CH', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
              })}

              <a className="node-delete-button hidden">
                <span className="icon is-medium">
                  <i className="fa fa-trash fa-lg" />
                </span>
              </a>
            </div>

            <div style={{ whiteSpace: 'pre-wrap' }}>{note.text}</div>
          </article>
        ))}

        <div className="note-form">
          <article className="note-box">
            <div className="note-header">
              {new Date().toLocaleDateString('en-CH', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
              })}
            </div>

            <textarea
              rows={3}
              name="text"
              className="textarea note-textarea"
              placeholder="New note..."
            />
          </article>
        </div>
      </div>
    );
  }
}

export default NoteBoxes;
