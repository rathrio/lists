import React, { Fragment } from 'react';
import * as Mousetrap from 'mousetrap';

import API from '../../utils/api';
import Rails from '../../utils/rails';
import OmniBar from './OmniBar';
import ItemList from './ItemList';
import Spinner from './Spinner';
import ScraperResults from './ScraperResults';
import { Item, ScraperResult } from '..';

interface Props {
  readonly items: Item[];
}

interface State {
  query: string;
  items: Item[];
  scraperResults: ScraperResult[];
  showSpinner: boolean;
}

export default class Items extends React.Component<Props, State> {
  readonly state: State = {
    query: 's[todo] ',
    items: this.props.items,
    scraperResults: [],
    showSpinner: false
  };

  private readonly tagsRgx = /\b(s|t|y)\[([^\]]+)\]/g;

  componentDidMount() {
    const csrfToken = Rails.authenticityToken();
    API.defaults.headers.common['X-CSRF-Token'] = csrfToken;

    Mousetrap.bind('s', this.toggleItemStatusFilter);
  }

  onOmniInput = (e: any) => this.filter(e.target.value);

  onTagFilter = (tag: string, options: { append: boolean }) => {
    if (!options.append) {
      this.filter(tag);
      return;
    }

    const currentQuery = this.state.query;
    this.filter(`${currentQuery} ${tag}`.trim());
  };

  onOmniSubmit = (e: any) => {
    this.showSpinner();
    const query = e.target.value.replace(this.tagsRgx, '').trim();

    API.get('/scraper_results', { params: { query } }).then(
      (response) => {
        this.hideSpinner();
        this.setState({ scraperResults: response.data });
      },
      (error) => {
        console.log(error);
      }
    );
  };

  onResultAdd = (result: ScraperResult) => {
    API.post('/scraper_results/import', { scraper_results: result }).then(
      (response) => {
        this.setState({
          scraperResults: this.state.scraperResults.filter((r) => r !== result)
        });
        this.setState((prevState) => ({
          items: [response.data, ...prevState.items]
        }));
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
        this.setState((prevState) => ({
          items: prevState.items.map(
            (i) => (i.id === item.id ? response.data : i)
          )
        }));
      },
      (error) => {
        console.log(error);
      }
    );
  };

  onItemUpdateRating = (item: Item, rating: number) => {
    API.put(`/items/${item.id}/update_rating`, { rating }).then(
      (response) => {
        this.setState((prevState) => ({
          items: prevState.items.map(
            (i) => (i.id === item.id ? response.data : i)
          )
        }));
      },
      (error) => {
        console.log(error);
      }
    );
  };

  toggleItemStatusFilter = () => {
    const statusRgx = /\bs\[([^\]]+)\]/g;

    if (!this.state.query.match(statusRgx)) {
      this.setState((prevState) => ({ query: `s[todo] ${prevState.query}` }));
      return;
    }

    const newQuery = this.state.query.replace(statusRgx, (_, status) => {
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
    this.resetScraperResults();
    this.setState({ query: query.toString() });
  };

  showSpinner = () => this.setState({ showSpinner: true });
  hideSpinner = () => this.setState({ showSpinner: false });

  resetScraperResults = () => this.setState({ scraperResults: [] });

  remove = (item: Item) =>
    this.setState((prevState) => ({
      items: prevState.items.filter((i) => i !== item)
    }));

  escapeRgx = (str: string) =>
    str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&');

  filteredItems = (query: string) => {
    let { items } = this.state;

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
  };

  render() {
    const { query } = this.state;

    const scraperResults =
      this.state.scraperResults.length > 0 ? (
        <ScraperResults
          results={this.state.scraperResults}
          onAdd={this.onResultAdd}
        />
      ) : (
          ''
        );

    const spinner = this.state.showSpinner ? <Spinner /> : '';

    return (
      <Fragment>
        <OmniBar
          onInput={this.onOmniInput}
          onSubmit={this.onOmniSubmit}
          query={this.state.query}
        />

        <ItemList
          items={this.filteredItems(query)}
          onTagFilter={this.onTagFilter}
          onItemArchive={this.onItemArchive}
          onItemRestore={this.onItemRestore}
          onItemDelete={this.onItemDelete}
          onItemToggle={this.onItemToggle}
          onItemUpdateRating={this.onItemUpdateRating}
        />

        {spinner}
        {scraperResults}
      </Fragment>
    );
  }
}
