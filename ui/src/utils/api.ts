import axios from 'axios';

const BASE_URL =
  import.meta.env.VITE_BACKEND_API_BASE_URL ?? 'http://localhost:3000';

const API = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
  withCredentials: true,
});

export const publicAssetsUrl = (url: string): string => `${BASE_URL}${url}`;

(window as any).api = API;
export default API;
