import axios from 'axios'
import PropTypes from 'prop-types'
import React, { Component, Fragment } from 'react';
import OmniBar from './OmniBar'
import ItemList from './ItemList'
import Spinner from './Spinner'

const API = axios.create({
  baseURL: 'http://localhost:3000',
  timeout: 5000,
})

const ScraperResult = ({ result }) => {
  const thumbUrl = result.remote_image_url
  const date = result.date
  const year = new Date(date).getFullYear()
  const tags = result.tags.slice(0, 4)

  const onClick = () => {
    console.log("Clicked " + result.name);
  }

  return(
    <div className="box item-box scraper-result" data-balloon="Add to List" onClick={onClick}>
      <div className="level is-mobile">
        <div className="level-left is-mobile">
          <div className="level-item">
            <figure className="image is-64x64">
              <img src={thumbUrl} style={{ width: "64px", height: "64px", objectFit: "cover" }} />
            </figure>
          </div>

          <div className="level-item">
            <div className="subtitle is-4">
              {result.name}
            </div>
          </div>

          <div className="level-item">
            <span className="tag is-rounded is-light is-small">
              {year}
            </span>
          </div>

          {tags.map((tag) => {
            return(
              <div key={`scraper-result-tag-${tag}`} className="level-item is-hidden-touch item-tag">
                <span className="tag is-rounded is-light is-small">
                  {tag}
                </span>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}

const ScraperResults = ({ results }) => {
  const resultsList = results.map((result, index) => (
    <ScraperResult key={`scraper-result-${index}`} result={result} />
  ))

  return (
    <div className="scraper-results">
      <h4 className="subtitle is-4">Found on the interwebs</h4>
      {resultsList}
    </div>
  )
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

  resetScraperResults = () => this.setState({ scraperResults: [] })

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

  filter = (query) => {
    this.resetScraperResults()

    const items = this.props.items.filter((i) => (
      (this.match(i.name, query) || i.tags.some((t) => (this.match(t, query))))
    ))

    this.setState({ query: query, items: items })
  }

  render() {
    const scraperResults = (this.state.scraperResults.length > 0)
      ? (<ScraperResults results={this.state.scraperResults}/>)
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
