import Items from './Items';
import RootStore from '../stores/RootStore';

function MainSection(props: { store: RootStore }) {
  return <section className="section main-section">
    <div className="container">
      <Items store={props.store}/>
    </div>
  </section>;
}

export default MainSection;

