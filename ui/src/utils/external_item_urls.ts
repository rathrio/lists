import { Item } from "../interfaces";

export const pirateSearchUrl = (item: Item) => encodeURI(
  `https://thepiratebay.org/search/${item.name}`
);

export const youtubeSearchUrl = (item: Item) => encodeURI(
  `https://www.youtube.com/results?search_query=${item.name} ${item.year}`
);

export const googleSearchUrl = (item: Item) => encodeURI(
  `https://www.google.ch/search?q=${item.name} ${item.year}`
);

export const netflixSearchUrl = (item: Item) => encodeURI(
  `https://www.netflix.com/search?q=${item.name}`
);