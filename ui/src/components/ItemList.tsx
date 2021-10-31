import React from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';
import ItemBox from './ItemBox';
import ItemActions from './ItemActions';

interface Props {
  store: ItemStore;
}

@observer
class ItemList extends React.Component<Props> {
  render() {
    const { store } = this.props;

    const itemBoxes = store.filteredItems.map((i) => (
      <ItemBox key={`item-${i.id}`} item={i} store={store} />
    ));

    return (
      <div className="items-list">
        {itemBoxes}
        <ItemActions store={store} />
      </div>
    );
  }
}

export default ItemList;
