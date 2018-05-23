import PropTypes from 'prop-types'
import React, { Component, Fragment } from 'react';
import OmniBar from './OmniBar'
import ItemList from './ItemList'

const Spinner = () => (
  <div className="columns">
    <div className="column is-1 is-offset-5">
      <span className="icon is-large">
        <i className="fa fa-spinner fa-pulse fa-3x"></i>
      </span>
    </div>
  </div>
)

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

  onOmniSubmit = (e) => {
    this.setState({showSpinner: true})
    const query = e.target.value
    debugger
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