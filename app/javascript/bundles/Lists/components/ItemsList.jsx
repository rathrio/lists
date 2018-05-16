import PropTypes from 'prop-types'
import React, { Component, Fragment } from 'react';
import OmniBar from './OmniBar'
import ItemBox from './ItemBox'

export default class ItemsList extends Component {
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
    const itemsList = this.state.items.map((i) => (
      <ItemBox key={i.id} item={i} onTagClick={this.onTagClick} />
    ))

    return (
      <Fragment>
        <OmniBar onInput={this.onOmniInput} query={this.state.query} />
        <div className="items-list">
          {itemsList}
        </div>
      </Fragment>
    )
  }
}