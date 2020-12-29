export interface Image {
  thumb: { url: string };
  url: string;
}

export enum ItemStatus {
  Todo = 'todo',
  Doing = 'doing',
  Done = 'done'
}

export interface Item {
  id: number;
  list: string;
  fa_icon: string;
  list_id: number;
  name: string;
  description: string;
  quantity: number;
  scraped: boolean;
  status: ItemStatus;
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
  language?: string;
  first_done_at?: string
  image?: Image;
  remote_image_url?: string;
  recommended_by?: string;
  notes: Note[];
}

export interface ScraperResult {
  name: string;
  description: string;
  remote_image_url: string;
  date: string;
  tags: string[];
  links?: string[];
}

export interface Tag {
  /**
   * Display name, e.g. "Watching" for a status.
   */
  name: string;

  /**
   * Value used for filtering, e.g. "doing" for a status.
   */
  value?: string | number;
  type: 'tag' | 'status' | 'list' | 'year' | 'rating';
}

export interface Note {
  id: number;
  list_id: number;
  text: string;
  created_at: string;
}
