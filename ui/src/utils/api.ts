import axios from 'axios';

const BASE_URL = 'http://localhost:3000';

const API = axios.create({
  baseURL: BASE_URL,
  timeout: 10000
});

export const publicAssetsUrl = (url: string): string => `${BASE_URL}${url}`;

export default API;
