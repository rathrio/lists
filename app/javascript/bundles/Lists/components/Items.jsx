import axios from 'axios'
import PropTypes from 'prop-types'
import React, { Component, Fragment } from 'react';
import OmniBar from './OmniBar'
import ItemList from './ItemList'
import Spinner from './Spinner'

const BASE_URL = "http://localhost:3000"

const API = axios.create({
  baseURL: 'http://localhost:3000',
  timeout: 5000,
})

class ScraperResults extends Component {
  render() {
    return(
      <div className="scraper-results">
        <h4 className="subtitle is-4">Found on the interwebs</h4>
      </div>
    )
  }
}

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

  match = (str, query) => (
    str.toLowerCase().match(query.toLowerCase())
  )

  onOmniInput = (e) => this.filter(e.target.value)
  onTagClick = (tag) => this.filter(tag)

  showSpinner = () => this.setState({ showSpinner: true })
  hideSpinner = () => this.setState({ showSpinner: false })

  onOmniSubmit = (e) => {
    this.showSpinner()
    const query = e.target.value

    API.get('/scraper_results', { params: { query: query } })
      .then((response) => {
        this.hideSpinner()
        this.setState({ scraperResults: [1, 2, 4] })
        // TODO: set scraper results
      })
  }

  filter = (query) => {
    const items = this.props.items.filter((i) => (
      (this.match(i.name, query) || i.tags.some((t) => (this.match(t, query))))
    ))

    this.setState({ query: query, items: items })
  }

  render() {
    const scraperResults = (this.state.scraperResults.length > 0)
      ? (<ScraperResults items={this.state.scraperResults}/>)
      : ""

    const spinner = (this.state.showSpinner) ? (<Spinner />) : ""

    return (
      <Fragment>
        <OmniBar onInput={this.onOmniInput} onSubmit={this.onOmniSubmit} query={this.state.query} />
        <ItemList items={this.state.items} onTagClick={this.onTagClick} />
        {spinner}
        {scraperResults}
      </Fragment>
    )
  }
}