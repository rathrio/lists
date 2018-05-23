import PropTypes from 'prop-types'
import React, { Component, Fragment } from 'react';
import OmniBar from './OmniBar'
import ItemList from './ItemList'

export default class Items extends Component {
  constructor(props) {
    super(props)

    this.state = {
      query: "",
      items: this.props.items
    }
  }

  match = (str, query) => (
    str.toLowerCase().match(query.toLowerCase())
  )

  onOmniInput = (e) => this.filter(e.target.value)
  onTagClick = (tag) => this.filter(tag)

  filter = (query) => {
    const items = this.props.items.filter((i) => (
      (this.match(i.name, query) || i.tags.some((t) => (this.match(t, query))))
    ))

    this.setState({ query: query, items: items })
  }

  render() {
    return (
      <Fragment>
        <OmniBar onInput={this.onOmniInput} query={this.state.query} />
        <ItemList items={this.state.items} onTagClick={this.onTagClick} />
      </Fragment>
    )
  }
}