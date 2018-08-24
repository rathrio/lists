import { observable, computed, action } from 'mobx';
import { Item, ScraperResult } from '..';
import API from '../../utils/api';

/**
 * State managment for items overview.
 */
class ItemStore {
  readonly items = observable<Item>([]);
  readonly scraperResults = observable<ScraperResult>([]);

  @observable
  activeItem?: Item;

  @observable
  detailsModalVisible = false;

  @observable
  query = 's[todo] ';

  @observable
  spinnerVisible = false;

  /**
   * Indicates whether we should render all filter matches.
   */
  @observable
  allItemsVisible = false;

  private readonly tagsRgx = /\b(s|t|y)\[([^\]]+)\]/g;
  private readonly itemsToShow = 15;

  constructor(items: Item[]) {
    this.items.replace(items);
  }

  @action
  onOmniInput = (e: any) => this.filter(e.target.value);

  @action
  onTagFilter = (tag: string, options: { append: boolean }) => {
    if (!options.append) {
      this.filter(tag);
      return;
    }

    const currentQuery = this.query;
    this.filter(`${currentQuery} ${tag}`.trim());
  };

  @action
  onOmniSubmit = (e: any) => {
    e.preventDefault();

    this.showSpinner();
    const query = this.query.replace(this.tagsRgx, '').trim();

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
  onResultAdd = (result: ScraperResult) => {
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
  onItemArchive = (item: Item) => {
    API.delete(`/items/${item.id}`).then(
      (response) => {
        this.remove(item);
      },
      (error) => {
        console.log(error);
      }
    );
  };

  @action
  onItemRestore = (item: Item) => {
    API.put(`/items/${item.id}/restore`).then(
      (response) => {
        this.remove(item);
      },
      (error) => {
        console.log(error);
      }
    );
  };

  @action
  onItemDelete = (item: Item) => {
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
  onItemToggle = (item: Item) => {
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
  onItemUpdateRating = (item: Item, rating: number) => {
    this.update(item, { rating });
  };

  @action
  toggleItemStatusFilter = () => {
    const statusRgx = /\bs\[([^\]]+)\]/g;

    if (!this.query.match(statusRgx)) {
      this.query = `s[todo] ${this.query}`;
      return;
    }

    const newQuery = this.query.replace(statusRgx, (_, status) => {
      let nextStatus = '';
      switch (status) {
        case 'todo':
          nextStatus = 'doing';
          break;
        case 'doing':
          nextStatus = 'done';
          break;
        default:
          return '';
      }

      return `s[${nextStatus}]`;
    });

    this.filter(newQuery.trim());
  };

  @action
  filter = (query: string) => {
    this.doNotShowAllItems();
    this.resetScraperResults();
    this.query = query.toString();
  };

  @action
  showSpinner = () => this.spinnerVisible = true;

  @action
  hideSpinner = () => this.spinnerVisible = false;

  /**
   * Show all *filtered* items, because by default only the first 15 matches
   * are rendered for fast rerendering.
   */
  @action
  showAllItems = () => this.allItemsVisible = true;

  @action
  doNotShowAllItems = () => this.allItemsVisible = false;

  @action
  showDetailsModal = () => this.detailsModalVisible = true;

  @action
  hideDetailsModal = () => this.detailsModalVisible = false;

  @action
  showItemDetails = (item: Item) => {
    this.activeItem = item;
    this.showDetailsModal();
  };

  @action
  resetScraperResults = () => this.scraperResults.replace([]);

  @action
  remove = (item: Item) => {
    this.items.remove(item);
  }

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
  }

  private match = (str: string, query: string) =>
    str.toLowerCase().match(this.escapeRgx(query.toLowerCase())) !== null;

  private matchItem = (item: Item, query: string) =>
    this.match(item.name, query) ||
    item.tags.some((tag) => this.match(tag, query)) ||
    (item.year && this.match(item.year.toString(), query));

  private escapeRgx = (str: string) =>
    str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&');

  @computed
  get allFilteredItems(): Item[] {
    const query = this.query;
    let items = this.items.slice();

    if (!query) {
      return items;
    }

    const q = query
      .replace(this.tagsRgx, (_, type, tag) => {
        switch (type) {
          case 's':
            items = items.filter((item) => item.status === tag.toLowerCase());
            break;
          case 'y':
            items = items.filter(
              (item) => item.year && this.match(item.year.toString(), tag)
            );
            break;
          case 't':
            items = items.filter((item) =>
              item.tags.some((t) => this.match(t, tag))
            );
            break;
          default:
            console.log(`Unknown tag type ${type}`);
            break;
        }

        return '';
      })
      .trim();

    if (q) {
      items = items.filter((item) => this.matchItem(item, q));
    }

    return items;
  }

  @computed
  get filteredItems(): Item[] {
    if (this.allItemsVisible) {
      return this.allFilteredItems;
    }

    return this.allFilteredItems.slice(0, this.itemsToShow);
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
  }
}

export default ItemStore;
