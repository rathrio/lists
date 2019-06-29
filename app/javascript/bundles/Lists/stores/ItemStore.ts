import { observable, computed, action } from 'mobx';
import _ from 'lodash';
import { Item, ScraperResult, Tag } from '..';
import API from '../../utils/api';

interface OmnibarFilter {
  query: string;
  tags: Tag[];
}

/**
 * State management for items.
 */
class ItemStore {
  static itemsToShow = 15;
  static statusRank = {
    doing: 0,
    todo: 1,
    done: 2
  };

  /**
   * All items provided by Rails.
   */
  readonly items = observable<Item>([]);

  /**
   * Results rendered when searching the web.
   */
  readonly scraperResults = observable<ScraperResult>([]);

  /**
   * Tags in omnibar.
   */
  readonly tags = observable<Tag>([]);

  /**
   * The query in the omnibar.
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

  /**
   * Whether we should render all filter matches.
   */
  @observable
  allItemsVisible = false;

  constructor(items: Item[]) {
    this.items.replace(items);
  }

  @action
  addTagFilter = (tag: Tag, { append = false }) => {
    this.doNotShowAllItems();

    if (append) {
      // Append if it's not already in there.
      if (!this.tags.some((t) => _.isEqual(t, tag))) {
        this.tags.push(tag);
      }
    } else {
      this.tags.replace([tag]);
    }
  };

  @action
  scrape = () => {
    this.showSpinner();
    const query = this.query;

    API.get('/scraper_results', { params: { query } }).then(
      (response) => {
        this.hideSpinner();
        this.scraperResults.replace(response.data);
      },
      (error) => {
        console.log(error);
      }
    );
  };

  @action
  importScraperResult = (result: ScraperResult) => {
    API.post('/scraper_results/import', { scraper_results: result }).then(
      (response) => {
        this.scraperResults.remove(result);
        this.items.unshift(response.data);
      },
      (error) => {
        console.log(error);
      }
    );
  };

  @action
  archive = (item: Item) => {
    API.delete(`/items/${item.id}`).then(
      (response) => {
        this.remove(item);
        Object.assign(item, response.data);
      },
      (error) => {
        console.log(error);
      }
    );
  };

  @action
  restore = (item: Item) => {
    API.put(`/items/${item.id}/restore`).then(
      (response) => {
        this.remove(item);
        Object.assign(item, response.data);
      },
      (error) => {
        console.log(error);
      }
    );
  };

  @action
  delete = (item: Item) => {
    if (!window.confirm('Are you sure?')) {
      return;
    }

    API.delete(`/items/${item.id}/really_destroy`).then(
      (response) => {
        this.remove(item);
      },
      (error) => {
        console.log(error);
      }
    );
  };

  @action
  toggleStatus = (item: Item) => {
    API.put(`/items/${item.id}/toggle_status`).then(
      (response) => {
        Object.assign(item, response.data);
      },
      (error) => {
        console.log(error);
      }
    );
  };

  @action
  updateRating = (item: Item, rating: number) => {
    this.update(item, { rating });
  };

  @action
  toggleItemStatusFilter = () => {
    this.doNotShowAllItems();
    const currentStatusTag = this.tags.find((tag) => tag.type === 'status');

    if (!currentStatusTag) {
      this.tags.unshift({ value: 'todo', type: 'status', name: 'Todo' });
      return;
    }

    switch (currentStatusTag.value) {
      case 'todo':
        Object.assign(currentStatusTag, { value: 'doing', name: 'Doing' });
        break;
      case 'doing':
        Object.assign(currentStatusTag, { value: 'done', name: 'Done' });
        break;
      case 'done':
        this.tags.remove(currentStatusTag);
      default:
        break;
    }
  };

  @action
  filter = (query: string) => {
    this.doNotShowAllItems();
    this.resetScraperResults();
    this.unfocusItem();
    this.query = query.toString();
  };

  @action
  showSpinner = () => (this.spinnerVisible = true);

  @action
  hideSpinner = () => (this.spinnerVisible = false);

  /**
   * Show all *filtered* items, because by default only the first 15 matches
   * are rendered for fast rerendering.
   */
  @action
  showAllItems = () => (this.allItemsVisible = true);

  @action
  doNotShowAllItems = () => (this.allItemsVisible = false);

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
    this.showDetailsModal();
  };

  @action
  showRandomItemDetails = () => {
    if (!this.itemsTodo.length) {
      return;
    }

    const item = _.sample(this.itemsTodo)!;
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
      (response) => {
        Object.assign(item, response.data);
      },
      (error) => {
        console.log(error);
      }
    );
  };

  @action
  removeTagFilter = (tag: Tag) => {
    this.doNotShowAllItems();
    this.tags.remove(tag);
  };

  @action
  clearTagFilter = () => {
    this.doNotShowAllItems();
    this.tags.clear();
  };

  @action
  popTagFilter = () => {
    this.doNotShowAllItems();
    this.tags.pop();
  };

  /**
   * To sync with letterboxd from time to time.
   *
   * https://letterboxd.com/about/importing-data/
   */
  @action
  exportItems = () => {
    const contents = encodeURI(this.toCsv(this.allFilteredItems));

    const timestamp = new Date().toISOString().slice(0, 10);
    let filename = `${timestamp}-items`;
    if (this.omnibarFilter.query) {
      filename += `-query_${this.omnibarFilter.query.replace(/[^a-z0-9]+/gi, '-')}`;
    }

    _.sortBy(this.omnibarFilter.tags, 'type').forEach((tag) => {
      filename += `-${tag.type}_${tag.value!.toString().replace(/[^a-z0-9]+/gi, '-')}`;
    });
    filename += '.csv';

    const link = document.createElement('a');
    link.setAttribute('href', contents);
    link.setAttribute('download', filename);
    link.click();
  };

  private toCsv = (items: Item[]): string => {
    let contents = 'data:text/csv;charset=utf-8,';
    const header = 'Title,Year,Rating\n';
    contents += header;
    contents += items
      .map((item) => `"${item.name}","${item.year}","${item.rating}"`)
      .join('\n');
    return contents;
  };

  private match = (str: string, query: string) => {
    return (
      str.toLowerCase().match(this.escapeRgx(query.toLowerCase())) !== null
    );
  };

  private matchItem = (item: Item, query: string) => {
    return (
      this.match(item.name, query) ||
      item.tags.some((tag) => this.match(tag, query)) ||
      (item.year && this.match(item.year.toString(), query))
    );
  };

  private escapeRgx = (str: string) => {
    return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&');
  };

  @computed
  get omnibarFilter(): OmnibarFilter {
    return {
      query: this.query,
      tags: this.tags
    };
  }

  /**
   * this.items with omnibar filter applied.
   *
   * Note that not all of them will be rendered.
   * @see filteredItems
   */
  @computed
  get allFilteredItems(): Item[] {
    const query = this.omnibarFilter.query;
    const tags = this.omnibarFilter.tags;
    let items = this.items.slice();

    tags.forEach((tag) => {
      switch (tag.type) {
        case 'tag':
          items = items.filter((item) =>
            item.tags.some((t) => t === tag.value)
          );
          break;
        case 'year':
          items = items.filter((item) => item.year === tag.value);
          break;
        case 'status':
          items = items.filter((item) => item.status === tag.value);
          break;
        case 'rating':
          items = items.filter((item) => item.rating === tag.value);
          break;
      }
    });

    if (query) {
      items = items.filter((item) => this.matchItem(item, query));
    }

    items = _.sortBy(items, (item) => ItemStore.statusRank[item.status]);
    return items;
  }

  @computed
  get itemsTodo(): Item[] {
    return this.items.filter((item) => item.status === 'todo');
  }

  /**
   * Only a subset of this.allFilteredItems by default (speeds up re-rendering).
   *
   * @see allFilteredItems
   */
  @computed
  get filteredItems(): Item[] {
    if (this.allItemsVisible) {
      return this.allFilteredItems;
    }

    return this.allFilteredItems.slice(0, ItemStore.itemsToShow);
  }

  @computed
  get hasMoreFilteredItems() {
    return this.allFilteredItems.length > this.filteredItems.length;
  }

  @computed
  get moreItemsToShow(): number {
    if (!this.hasMoreFilteredItems) {
      return 0;
    }

    return this.allFilteredItems.length - this.filteredItems.length;
  }

  isActive = (item: Item) => {
    return this.activeItem === item;
  };

  isFocused = (item: Item) => {
    return this.focusedItem === item;
  };
}

export default ItemStore;
