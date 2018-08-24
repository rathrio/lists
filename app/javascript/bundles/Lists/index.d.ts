export interface Image {
  thumb: { url: string };
  url: string;
}

export interface Item {
  id: number;
  list: string;
  list_id: number;
  name: string;
  description: string;
  quantity: number;
  scraped: boolean;
  status: 'todo' | 'doing' | 'done';
  human_status: string;
  tags: string[];
  user_id: number;
  year: number;
  rating?: number;
  created_at: string;
  updated_at: string;
  deleted: boolean;
  deleted_at: string;
  date: string;
  image?: Image;
  links?: string[];
  remote_image_url?: string;
}

export interface ScraperResult {
  name: string;
  description: string;
  remote_image_url: string;
  date: string;
  tags: string[];
  links?: string[];
}