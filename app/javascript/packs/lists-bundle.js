import ReactOnRails from 'react-on-rails';

import HelloWorld from '../bundles/Lists/components/HelloWorld';
import ItemsList from '../bundles/Lists/components/ItemsList';

// This is how react_on_rails can see the HelloWorld in the browser.
ReactOnRails.register({
  // HelloWorld,
  ItemsList
});
