import ReactOnRails from 'react-on-rails';
import '../bundles/utils/keyboard_shortcuts';
import Items from '../bundles/Lists/components/Items';

// This is how react_on_rails can see the Items component in the browser.
ReactOnRails.register({
  Items
});
