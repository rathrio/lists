export interface Image {
  thumb: { url: string };
  url: string;
}

export enum ItemStatus {
  Todo = 'todo',
  Doing = 'doing',
  Done = 'done',
}

// https://bulma.io/documentation/elements/image/#responsive-images-with-ratios
export type CoverAspectRatio = '2by3' | '3by4';

export interface List {
  id: number;
  name: string;
  description: string;
  fa_icon: string;
  cover_aspect_ratio: CoverAspectRatio;
}

export interface Item {
  id: number;
  list: string;
  fa_icon: string;
  list_id: number;
  name: string;
  original_name?: string;
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
  first_done_at?: string;
  image?: Image;
  remote_image_url?: string;
  recommended_by?: string;
  notes?: string;
  metadata?: object;
  seasons?: Season[];
}

export interface Season {
  id: number;
  name: string;
  overview: string;
  air_date: string;
  episode_count: number;
  season_number: number;
}

export interface ScraperResult {
  name: string;
  description: string;
  remote_image_url: string;
  date: string;
  tags: string[];
  links?: string[];
  metadata: object;
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
