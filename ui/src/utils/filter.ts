import _ from 'lodash';
import { Item } from '../interfaces';
import { toIdentifier } from './toIdentifier';

export enum Filter {
  Status = 'status',
  Year = 'year',
  Tag = 'tag',
  Rating = 'rating',
  RecommendedBy = 'recommended_by',
  Language = 'language',
  ReleasedAt = 'released_at',
  AddedAt = 'added_at',
  DoneAt = 'done_at',
}

export const FILTERS = [
  Filter.Status,
  Filter.Year,
  Filter.Tag,
  Filter.Rating,
  Filter.RecommendedBy,
  Filter.Language,
  Filter.ReleasedAt,
  Filter.AddedAt,
  Filter.DoneAt,
];

export const FILTER_RGX = /\w+\s*=\s*[^\s]+/g;

export interface FilterValue {
  filter: Filter;
  value: string;
}

/**
 * The query from the omnibar with structured filters.
 */
export interface Query {
  query: string;
  filterValues: FilterValue[];
}

export const buildQuery = (query: string): Query => {
  const filterMatches = query.match(FILTER_RGX) || [];
  const nameQuery = query.replace(FILTER_RGX, '').trim();

  const filterValues: FilterValue[] = filterMatches.map((match) => {
    const [filter, value] = match.split('=').map((str) => str.trim());

    return { filter: filter as Filter, value };
  });

  return { query: nameQuery, filterValues };
};

export const filter = (rawQuery: string, unfilteredItems: Item[]): Item[] => {
  const { query, filterValues } = buildQuery(rawQuery);
  let items = unfilteredItems.slice();

  filterValues.forEach((filterValue) => {
    const value = filterValue.value;
    switch (filterValue.filter) {
      case Filter.Rating:
        if (value === '0') {
          items = items.filter((item) => !item.rating);
        } else {
          items = items.filter((item) => item.rating === parseInt(value, 10));
        }
        break;

      case Filter.Year:
        items = items.filter((item) => item.year.toString().startsWith(value));
        break;

      case Filter.Tag:
        items = items.filter((item) =>
          item.tags.some((t) => toIdentifier(t).includes(toIdentifier(value)))
        );
        break;

      case Filter.RecommendedBy:
        items = items.filter(
          (item) =>
            item.recommended_by &&
            toIdentifier(item.recommended_by).includes(toIdentifier(value))
        );
        break;

      case Filter.Status:
        items = items.filter((item) => item.status === value.toLowerCase());
        break;

      case Filter.Language:
        items = items.filter((item) => item.language === value.toLowerCase());
        break;

      case Filter.AddedAt:
        items = items.filter((item) => item.created_at.startsWith(value));
        break;

      case Filter.DoneAt:
        items = items.filter((item) => item.first_done_at?.startsWith(value));
        break;

      case Filter.ReleasedAt:
        items = items.filter((item) => item.date?.startsWith(value));
        break;
    }
  });

  if (query) {
    items = items.filter((item) => matchItem(item, query));
  }

  return items;
};

const match = (str: string, query: string) => {
  return str.toLowerCase().includes(query.toLowerCase());
};

const matchItem = (item: Item, query: string) => {
  return match(item.name, query) || match(item.original_name ?? '', query);
};
