import { observable, computed } from 'mobx';
import { Item, ScraperResult } from '..';
import API from '../../utils/api';

class ItemStore {
  readonly items = observable<Item>([]);
  readonly scraperResults = observable<ScraperResult>([]);

  @observable
  query = 's[todo] ';

  @observable
  spinnerVisible = false;

  @observable
  allItemsVisible = false;

  private readonly tagsRgx = /\b(s|t|y)\[([^\]]+)\]/g;
  private readonly itemsToShow = 15;

  constructor(items: Item[]) {
    this.items.replace(items);
  }

  onOmniInput = (e: any) => this.filter(e.target.value);

  onTagFilter = (tag: string, options: { append: boolean }) => {
    if (!options.append) {
      this.filter(tag);
      return;
    }

    const currentQuery = this.query;
    this.filter(`${currentQuery} ${tag}`.trim());
  };

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

  onResultAdd = (result: ScraperResult) => {
    API.post('/scraper_results/import', { scraper_results: result }).then(
      (response) => {
        this.scraperResults.replace(this.scraperResults.filter((r) => r !== result));
        this.items.replace([response.data, ...this.items]);
      },
      (error) => {
        console.log(error);
      }
    );
  };

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

  onItemToggle = (item: Item) => {
    API.put(`/items/${item.id}/toggle_status`).then(
      (response) => {
        this.items.replace(this.items.map(
          (i) => (i.id === item.id ? response.data : i)
        ));
      },
      (error) => {
        console.log(error);
      }
    );
  };

  onItemUpdateRating = (item: Item, rating: number) => {
    API.put(`/items/${item.id}/update_rating`, { rating }).then(
      (response) => {
        this.items.replace(this.items.map(
          (i) => (i.id === item.id ? response.data : i)
        ));
      },
      (error) => {
        console.log(error);
      }
    );
  };

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

  match = (str: string, query: string) =>
    str.toLowerCase().match(this.escapeRgx(query.toLowerCase())) !== null;

  matchItem = (item: Item, query: string) =>
    this.match(item.name, query) ||
    item.tags.some((tag) => this.match(tag, query)) ||
    (item.year && this.match(item.year.toString(), query));

  filter = (query: string) => {
    this.doNotShowAllItems();
    this.resetScraperResults();
    this.query = query.toString();
  };

  showSpinner = () => this.spinnerVisible = true;
  hideSpinner = () => this.spinnerVisible = false;

  showAllItems = () => this.allItemsVisible = true;
  doNotShowAllItems = () => this.allItemsVisible = false;

  resetScraperResults = () => this.scraperResults.replace([]);

  remove = (item: Item) => this.items.replace(this.items.filter((i) => i !== item));

  escapeRgx = (str: string) =>
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
}

export default ItemStore;
