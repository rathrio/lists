import axios from 'axios'
import PropTypes from 'prop-types'
import React, { Component, Fragment } from 'react';
import OmniBar from './OmniBar'
import ItemList from './ItemList'
import Spinner from './Spinner'
import ScraperResults from './ScraperResults'
import ReactOnRails from 'react-on-rails';

const API = axios.create({
  timeout: 10000,
})

export default class Items extends Component {
  constructor(props) {
    super(props)

    this.state = {
      query: "",
      items: this.props.items,
      scraperResults: [],
      showSpinner: false
    }
  }

  componentDidMount() {
    const csrfToken = ReactOnRails.authenticityToken();
    API.defaults.headers.common['X-CSRF-Token'] = csrfToken
  }

  match = (str, query) => (
    str.toLowerCase().match(query.toLowerCase())
  )

  matchItem = (item, query) => (
    this.match(item.name, query)
    || item.tags.some((tag) => (this.match(tag, query)))
    || (item.year && this.match(item.year.toString(), query))
  )

  onOmniInput = (e) => this.filter(e.target.value)
  onTagClick = (tag) => this.filter(tag)

  showSpinner = () => this.setState({ showSpinner: true })
  hideSpinner = () => this.setState({ showSpinner: false })

  resetScraperResults = () => this.setState({ scraperResults: [] })

  remove = (item) => (
    this.setState(
      prevState => (
        { items: this.state.items.filter(i => (i !== item)) }
      )
    )
  )

  onOmniSubmit = (e) => {
    this.showSpinner()
    const query = e.target.value

    API.get('/scraper_results', { params: { query: query } }).then(
      (response) => {
        this.hideSpinner()
        this.setState({ scraperResults: response.data })
      },
      (error) => {
        console.log(error)
      }
    )
  }

  onResultAdd = (result) => {
    API.post('/scraper_results/import', { scraper_results: result }).then(
      (response) => {
        this.setState({ scraperResults: this.state.scraperResults.filter(r => (r !== result)) })
        this.setState(prevState => ({ items: [response.data, ...prevState.items] }))
      },
      (error) => {
        console.log(error)
      }
    )
  }

  onItemArchive = (item) => {
    API.delete(`/items/${item.id}`).then(
      (response) => {
        this.remove(item)
      },
      (error) => {
        console.log(error)
      }
    )
  }

  onItemRestore = (item) => {
    API.put(`/items/${item.id}/restore`).then(
      (response) => {
        this.remove(item)
      },
      (error) => {
        console.log(error)
      }
    )
  }

  onItemDelete = (item) => {
    API.delete(`/items/${item.id}/really_destroy`).then(
      (response) => {
        this.remove(item)
      },
      (error) => {
        console.log(error)
      }
    )
  }

  onItemToggle = (item) => {
    API.put(`/items/${item.id}/toggle_status`).then(
      (response) => {
        this.setState(prevState => (
          { items: prevState.items.map(i => (i.id === item.id) ? response.data : i) }
        ))
      },
      (error) => {
        console.log(error)
      }
    )
  }

  filter = (query) => {
    this.resetScraperResults()
    this.setState({ query: query.toString() })
  }

  escapeRgx = (str) => str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")


  filteredItems = (query) => {
    let items = this.state.items

    if (query) {
      items = this.state.items.filter(item => this.matchItem(item, this.escapeRgx(query)))
    }

    return items
  }

  render() {
    const query = this.state.query

    const scraperResults = (this.state.scraperResults.length > 0)
      ? (<ScraperResults results={this.state.scraperResults} onAdd={this.onResultAdd} />)
      : ""

    const spinner = (this.state.showSpinner) ? (<Spinner />) : ""

    return (
      <Fragment>
        <OmniBar onInput={this.onOmniInput} onSubmit={this.onOmniSubmit} query={this.state.query} />

        <ItemList
          items={this.filteredItems(query)}
          onTagClick={this.onTagClick}
          onItemArchive={this.onItemArchive}
          onItemRestore={this.onItemRestore}
          onItemDelete={this.onItemDelete}
          onItemToggle={this.onItemToggle} />

        {spinner}
        {scraperResults}
      </Fragment>
    )
  }
}
