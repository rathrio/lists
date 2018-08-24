import React from 'react';
import { observer } from 'mobx-react';
import ItemStore from '../stores/ItemStore';
import ItemBox from './ItemBox';
import ShowMoreItemsButton from './ShowMoreItemsButton';

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
        <ShowMoreItemsButton store={store} />
      </div>
    );
  }
}

export default ItemList;
