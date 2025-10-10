import { action, autorun, computed, makeObservable, observable } from 'mobx';
import _ from 'lodash';
import API from '../utils/api';
import { Item, List, ScraperResult, Season, Tag } from '../interfaces';
import RootStore from './RootStore';
import { googleSearchUrl, pirateSearchUrl } from '../utils/externalItemUrls';
import Mousetrap from 'mousetrap';
import {
  buildQuery,
  filter,
  Filter,
  FILTERS,
  FILTER_RGX,
} from '../utils/filter';
import { toIdentifier } from '../utils/toIdentifier';
import { AxiosResponse } from 'axios';

function parseSeasons(metadata: any): Season[] {
  if (!metadata || !metadata['seasons']) {
    console.error('Invalid metadata format or missing seasons data:', metadata);
    return [];
  }

  return metadata['seasons'].map((season: any) => ({
    id: season['id'],
    name: season['name'],
    overview: season['overview'],
    air_date: season['air_date'],
    episode_count: season['episode_count'],
    season_number: season['season_number'],
  }));
}

/**
 * State management for items.
 */
class ItemStore {
  static statusRank = {
    doing: 0,
    todo: 1,
    done: 2,
  };

  /**
   * All items provided by the backend.
   */
  readonly items = observable<Item>([]);

  @observable
  isLoading = false;

  /**
   * Results rendered when searching the web.
   */
  readonly scraperResults = observable<ScraperResult>([]);

  /**
   * The raw query in the omnibar.
   */
  @observable
  query = '';

  /**
   * The item to show in the details modal.
   */
  @observable
  activeItem?: Item;

  /**
   * The item focused in the overview.
   */
  @observable
  focusedItem?: Item;

  /**
   * Whether to show the details modal.
   */
  @observable
  detailsModalVisible = false;

  /**
   * Whether to show the spinner in the scraper results area.
   */
  @observable
  spinnerVisible = false;

  private rootStore: RootStore;

  constructor(rootStore: RootStore) {
    makeObservable(this);
    this.rootStore = rootStore;
    this.setupShortcuts();

    autorun(() => {
      const activeList = rootStore.listStore.activeList;
      if (!activeList) {
        return;
      }
      this.handleListChange(activeList);
    });
  }

  private handleListChange = action((activeList: List) => {
    this.query = '';
    this.scraperResults.clear();
    this.items.clear();

    if (activeList.name === 'Archive') {
      this.loadArchive();
    } else {
      this.loadItems(activeList);
    }
  });

  private setupShortcuts = () => {
    Mousetrap.bind('R', (e) => {
      e.preventDefault();
      this.refreshMetadata();
    });

    Mousetrap.bind('r', (e) => {
      e.preventDefault();
      this.showRandomItemDetails();
    });

    Mousetrap.bind('enter', (e) => {
      e.preventDefault();
      this.showFocusedItemDetails();
    });

    Mousetrap.bind(['j', 'tab'], (e) => {
      // Tab should only work outside of details modal.
      if (this.detailsModalVisible && e.key === 'Tab') {
        return;
      }

      e.preventDefault();
      this.focusNextItem();
    });

    Mousetrap.bind(['k', 'shift+tab'], (e) => {
      // Tab should only work outside of details modal.
      if (this.detailsModalVisible && e.key === 'Tab') {
        return;
      }

      e.preventDefault();
      this.focusPreviousItem();
    });

    Mousetrap.bind('l', (e) => {
      if (!this.focusedItem) {
        return;
      }

      e.preventDefault();
      const item = this.focusedItem;
      window.open(googleSearchUrl(item), '_blank');
    });

    Mousetrap.bind('p', (e) => {
      if (!this.focusedItem) {
        return;
      }

      e.preventDefault();
      const item = this.focusedItem;
      window.open(pirateSearchUrl(item), '_blank');
    });

    Mousetrap.bind('g e', (e) => {
      if (this.detailsModalVisible) {
        return;
      }

      e.preventDefault();
      this.exportItems();
    });

    Mousetrap.bind('g E', (e) => {
      if (this.detailsModalVisible) {
        return;
      }

      e.preventDefault();
      this.exportItems('all');
    });
  };

  @action
  private loadItems = (list: List) => {
    this.isLoading = true;

    API.get(`/lists/${list.id}/items`)
      .then(
        action((response) => {
          this.items.replace(response.data);
        })
      )
      .finally(action(() => (this.isLoading = false)));
  };

  @action
  private loadArchive = () => {
    API.get(`/items/archived`).then(
      action((response) => {
        this.items.replace(response.data);
      })
    );
  };

  @action
  autoComplete = () => {
    if (!this.canAutoComplete) {
      return;
    }

    this.query = this.autoCompleteSuggestion;
  };

  @action
  addTagFilter = (tag: Tag, { append = false }) => {
    if (!append) {
      this.query = this.query.replace(FILTER_RGX, '').trim();
    }

    const value = tag.value ? toIdentifier(tag.value.toString()) : 0;
    this.query = `${this.query} ${tag.type}=${value}`.trim();
  };

  @action
  scrape = () => {
    const activeList = this.rootStore.listStore.activeList!;
    this.showSpinner();
    const { query, filterValues } = buildQuery(this.query);

    API.get(`/lists/${activeList.id}/scraper_results`, {
      params: { query, filter_values: filterValues },
    }).then(
      action((response) => {
        this.hideSpinner();
        this.scraperResults.replace(response.data);
      }),
      action((error) => {
        this.hideSpinner();
        console.error(error);
        alert(error);
      })
    );
  };

  @action
  importScraperResult = (result: ScraperResult) => {
    const activeList = this.rootStore.listStore.activeList!;
    API.post(`/lists/${activeList.id}/scraper_results/import`, {
      scraper_results: result,
    }).then(
      action((response) => {
        this.scraperResults.remove(result);
        this.items.unshift(response.data);
        this.notificationStore.showNotification(`Added "${result.name}"`);
      }),
      (error) => {
        console.error(error);
        this.notificationStore.showNotification(
          `Failed to import "${result.name}"`,
          'is-danger'
        );
      }
    );
  };

  /**
   * @return true when the user confirms archival
   */
  @action
  archive = (item: Item): boolean => {
    if (!window.confirm('Are you sure?')) {
      return false;
    }

    API.delete(`/items/${item.id}`).then(
      action((response) => {
        this.remove(item);
        // Image in deleted response is no longer present. Let's keep the one we
        // have in state here for now.
        delete response.data.image;
        Object.assign(item, response.data);
      }),
      (error) => {
        console.error(error);
      }
    );

    return true;
  };

  @action
  restore = (item: Item) => {
    API.put(`/items/${item.id}/restore`).then(
      action((response) => {
        this.remove(item);
        Object.assign(item, response.data);
        this.notificationStore.showNotification(
          `Sent "${item.name}" back to "${item.list}"`
        );
      }),
      (error) => {
        console.error(error);
      }
    );
  };

  @action
  delete = (item: Item) => {
    if (
      !window.confirm(
        'Are you sure you want to delete this item for real real this time?'
      )
    ) {
      return;
    }

    API.delete(`/items/${item.id}/really_destroy`).then(
      action((_response) => {
        this.remove(item);
        this.notificationStore.showNotification(`Deleted "${item.name}"`);
      }),
      (error) => {
        console.error(error);
        this.notificationStore.showNotification(
          `Could not delete "${item.name}"`,
          'is-danger'
        );
      }
    );
  };

  @action
  toggleStatus = (item: Item) => {
    API.put(`/items/${item.id}/toggle_status`).then(
      action((response) => {
        Object.assign(item, response.data);
      }),
      (error) => {
        console.error(error);
      }
    );
  };

  @action
  updateRating = (item: Item, rating: number) => {
    this.update(item, { rating });
  };

  @action
  filter = (query: string) => {
    this.resetScraperResults();
    this.unfocusItem();
    this.query = query.toString();
  };

  @action
  showSpinner = () => (this.spinnerVisible = true);

  @action
  hideSpinner = () => (this.spinnerVisible = false);

  @action
  showDetailsModal = () => (this.detailsModalVisible = true);

  @action
  hideDetailsModal = () => {
    this.activeItem = undefined;
    this.detailsModalVisible = false;
  };

  @action
  showItemDetails = (item: Item) => {
    this.activeItem = item;
    this.fetchMetadata();

    this.showDetailsModal();
  };

  updateActiveItemMetadataFromPromise(
    promise: Promise<AxiosResponse<any, any>>
  ) {
    promise.then(
      action((response) => {
        if (this.activeItem) {
          this.activeItem.metadata = response.data;
          this.activeItem.seasons = parseSeasons(response.data);
        }
      }),
      (error) => {
        console.error(error);
      }
    );
  }

  fetchMetadata = () => {
    if (!this.activeItem) {
      return;
    }

    this.updateActiveItemMetadataFromPromise(
      API.get(`/items/${this.activeItem.id}/metadata`)
    );
  };

  refreshMetadata = () => {
    if (!this.activeItem) {
      return;
    }

    this.updateActiveItemMetadataFromPromise(
      API.post(`/items/${this.activeItem.id}/refresh_metadata`)
    );
  };

  @action
  showRandomItemDetails = () => {
    if (!this.filteredItems.length) {
      return;
    }

    const item = _.sample(this.filteredItems)!;
    this.showItemDetails(item);
  };

  @action
  showFocusedItemDetails = () => {
    if (!this.focusedItem) {
      return;
    }

    this.showItemDetails(this.focusedItem);
  };

  @action
  focusNextItem = () => {
    if (this.filteredItems.length === 0) {
      return;
    }

    // Focus the first item if none is focused yet.
    if (!this.focusedItem) {
      this.focusItem(this.filteredItems[0]);
      return;
    }

    const focusedIndex = this.filteredItems.indexOf(this.focusedItem);

    // Focus the first item if the last one is focused.
    if (focusedIndex === this.filteredItems.length - 1) {
      this.focusItem(this.filteredItems[0]);
      return;
    }

    this.focusItem(this.filteredItems[focusedIndex + 1]);
  };

  @action
  focusPreviousItem = () => {
    if (this.filteredItems.length === 0) {
      return;
    }

    // Focus the last item if none is focused yet.
    if (!this.focusedItem) {
      this.focusItem(this.filteredItems[this.filteredItems.length - 1]);
      return;
    }

    const focusedIndex = this.filteredItems.indexOf(this.focusedItem);

    // Focus the last item if the first one is focused.
    if (focusedIndex === 0) {
      this.focusItem(this.filteredItems[this.filteredItems.length - 1]);
      return;
    }

    this.focusItem(this.filteredItems[focusedIndex - 1]);
  };

  @action
  focusItem = (item: Item) => {
    this.focusedItem = item;

    if (this.detailsModalVisible) {
      this.activeItem = item;
    }
  };

  @action
  unfocusItem = () => {
    this.focusedItem = undefined;
  };

  @action
  resetScraperResults = () => this.scraperResults.replace([]);

  @action
  remove = (item: Item) => {
    this.items.remove(item);
  };

  @action
  update = (item: Item, attributes: Partial<Item>) => {
    API.put(`/items/${item.id}`, { item: attributes }).then(
      action((response) => {
        Object.assign(item, response.data);
      }),
      (error) => {
        console.error(error);
      }
    );
  };

  /**
   * To sync with letterboxd from time to time.
   *
   * https://letterboxd.com/about/importing-data/
   */
  @action
  exportItems = (format: 'letterboxd' | 'all' = 'letterboxd') => {
    const newLineRgx = /(\r\n|\n|\r)/gm;
    const quoteRgx = /"/gm;
    let header = 'Title,Year,Rating,WatchedDate';
    let builder = (item: Item) =>
      `"${item.name}","${item.year}","${item.rating ?? ''}","${
        item.first_done_at ?? ''
      }"`;

    if (format === 'all') {
      header =
        'id,name,original_name,description,status,tags,year,rating,language,first_done_at,recommended_by';
      builder = (item: Item) =>
        `"${item.id}","${item.name}","${item.original_name}","${item.description
          .replace(quoteRgx, '""')
          .replace(newLineRgx, '')}","${item.status}","${item.tags.join(
          ';'
        )}","${item.year}","${item.rating}","${item.language}","${
          item.first_done_at
        }","${item.recommended_by}"`;
    }

    const csv = this.toCsv(this.filteredItems, header, builder);
    const contents = encodeURI(csv);

    const timestamp = new Date().toISOString().slice(0, 10);
    let filename = `${timestamp}-items`;
    if (this.query.length) {
      filename += `-query_${this.query.replace(/[^a-z0-9]+/gi, '-')}`;
    }

    filename += '.csv';

    const link = document.createElement('a');
    link.setAttribute('href', contents);
    link.setAttribute('download', filename);
    link.click();
  };

  private toCsv = (
    items: Item[],
    header: string,
    rowBuilder: (item: Item) => string
  ): string => {
    let contents = 'data:text/csv;charset=utf-8,';
    contents += header + '\n';
    contents += items.map(rowBuilder).join('\n');
    return contents;
  };

  @computed
  get knownYears(): number[] {
    return _.uniq(this.items.map((item) => item.year)).sort();
  }

  @computed
  get knownTagIdentifiers(): string[] {
    return _.chain(this.items)
      .flatMap((item) => item.tags.map(toIdentifier))
      .uniq()
      .value()
      .sort();
  }

  @computed
  get knownRecommenderIdentifiers(): string[] {
    return _.chain(this.items)
      .flatMap((item) =>
        (item.recommended_by || '').split(',').map(toIdentifier)
      )
      .uniq()
      .value()
      .sort();
  }

  @computed
  get knownLanguages(): string[] {
    return _.chain(this.items)
      .map((item) => item.language)
      .compact()
      .uniq()
      .value();
  }

  @computed
  get knownDoneAts(): string[] {
    return _.chain(this.items)
      .map((item) => item.first_done_at)
      .compact()
      .uniq()
      .value();
  }

  @computed
  get knownReleasedAts(): string[] {
    return _.chain(this.items)
      .map((item) => item.date)
      .compact()
      .uniq()
      .value();
  }

  @computed
  get knownAddedAts(): string[] {
    return _.chain(this.items)
      .map((item) => item.created_at.substring(0, 10))
      .uniq()
      .value();
  }

  @computed
  get autoCompleteSuggestion(): string {
    if (!this.query.length) {
      return '';
    }

    const reversedTokens = this.query.split(/\s+/).reverse();
    const lastToken = reversedTokens[0];

    if (!lastToken.length) {
      return this.query;
    }

    // Keyword values, e.g. "horror"
    if (lastToken.includes('=')) {
      const [filter, value] = lastToken.split('=').map((str) => str.trim());
      let valueSuggestion = value;

      switch (filter) {
        case Filter.Rating:
          if (!value) {
            valueSuggestion = _.sample([0, 1, 2, 3, 4, 5])!.toString();
          }
          break;

        case Filter.Year:
          if (!value) {
            valueSuggestion = (_.sample(this.knownYears) || 1991).toString();
          } else {
            valueSuggestion = (
              this.knownYears.find((year) =>
                year.toString().startsWith(value)
              ) || value
            ).toString();
          }
          break;

        case Filter.Tag:
          if (!value) {
            valueSuggestion = (
              _.sample(this.knownTagIdentifiers) || ''
            ).toString();
          } else {
            valueSuggestion =
              this.knownTagIdentifiers.find((tag) =>
                tag.toLowerCase().startsWith(value.toLowerCase())
              ) || value;
          }
          break;

        case Filter.RecommendedBy:
          if (!value) {
            valueSuggestion = (
              _.sample(this.knownRecommenderIdentifiers) || ''
            ).toString();
          } else {
            valueSuggestion =
              this.knownRecommenderIdentifiers.find((rec) =>
                rec.toLowerCase().startsWith(value.toLowerCase())
              ) || value;
          }
          break;

        case Filter.Status:
          valueSuggestion =
            ['todo', 'done', 'doing'].find((status) =>
              status.toLowerCase().startsWith(value.toLowerCase())
            ) || value;
          break;

        case Filter.Language:
          if (!value) {
            valueSuggestion = _.sample(this.knownLanguages) || '';
          } else {
            valueSuggestion =
              this.knownLanguages.find((lang) =>
                lang.toLowerCase().startsWith(value.toLowerCase())
              ) || value;
          }
          break;

        case Filter.AddedAt:
          if (!value) {
            valueSuggestion = _.sample(this.knownAddedAts) || '';
          } else {
            valueSuggestion =
              this.knownAddedAts.find((addedAt) =>
                addedAt.startsWith(value.toLowerCase())
              ) || value;
          }
          break;

        case Filter.ReleasedAt:
          if (!value) {
            valueSuggestion = _.sample(this.knownReleasedAts) || '';
          } else {
            valueSuggestion =
              this.knownReleasedAts.find((releasedAt) =>
                releasedAt.startsWith(value.toLowerCase())
              ) || value;
          }
          break;

        case Filter.DoneAt:
          if (!value) {
            valueSuggestion = _.sample(this.knownDoneAts) || '';
          } else {
            valueSuggestion =
              this.knownDoneAts.find((doneAt) =>
                doneAt.startsWith(value.toLowerCase())
              ) || value;
          }
          break;
      }

      return this.query.replace(
        new RegExp(`${_.escapeRegExp(value)}$`),
        valueSuggestion.replace(new RegExp(_.escapeRegExp(value), 'i'), value)
      );
    }

    // Keyword, e.g. "tag="
    const kw = FILTERS.find((keyword) => keyword.startsWith(lastToken));
    if (!kw) {
      return this.query;
    }

    const kwSuggestion =
      this.query.replace(new RegExp(`${_.escapeRegExp(lastToken)}$`), kw) + '=';
    return kwSuggestion;
  }

  get canAutoComplete(): boolean {
    return this.autoCompleteSuggestion.length > this.query.length;
  }

  /**
   * this.items with omnibar filter applied.
   *
   * Note that not all of them will be rendered.
   * @see filteredItems
   */
  @computed
  get filteredItems(): Item[] {
    const filtered = filter(this.query, this.items);
    const shuffled = _.shuffle(filtered);
    return _.sortBy(shuffled, (item) => ItemStore.statusRank[item.status]);
  }

  isActive = (item: Item) => {
    return this.activeItem === item;
  };

  isFocused = (item: Item) => {
    return this.focusedItem === item;
  };

  private get notificationStore() {
    return this.rootStore.notificationStore;
  }
}

export default ItemStore;
