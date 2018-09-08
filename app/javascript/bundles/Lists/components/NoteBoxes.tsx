import React, { CSSProperties } from 'react';
import ItemStore from '../stores/ItemStore';
import { Item } from '..';

interface Props {
  item: Item;
  store: ItemStore;
  style?: CSSProperties;
}

class NoteBoxes extends React.Component<Props> {
  render() {
    const { item, store, style } = this.props;

    return (
      <div className="note-boxes" style={style}>
        {item.notes.map((note) => (
          <article className="note-box">
            <div className="note-header">
              {new Date(note.created_at).toDateString()}

              <a className="node-delete-button hidden">
                <span className="icon is-medium">
                  <i className="fa fa-trash fa-lg" />
                </span>
              </a>
            </div>

            <div style={{ whiteSpace: 'pre-wrap' }}>{note.text}</div>
          </article>
        ))}

        <a>Add note</a>
      </div>
    );
  }
}

export default NoteBoxes;
