import axios from 'axios';

const API = axios.create({
  timeout: 10000
});

export default API;
