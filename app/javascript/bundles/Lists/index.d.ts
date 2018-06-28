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
  status: string;
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
}