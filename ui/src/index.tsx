import { createRoot } from 'react-dom/client';
import App from './components/App';
import '@fortawesome/fontawesome-free/css/all.min.css';
import './styles/index.scss';
import './styles/balloon.css';

// https://reactjs.org/blog/2022/03/08/react-18-upgrade-guide.html#updates-to-client-rendering-apis
const container = document.getElementById('root');
const root = createRoot(container!);
root.render(<App />);
