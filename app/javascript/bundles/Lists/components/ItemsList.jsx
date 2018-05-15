import React from 'react';

export default class ItemsList extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      search: "Some Movie",
      items: this.props.items
    }
  }

  onChange = (e) => {
    this.setState({search: e.target.value})
  }

  render() {
    return (
      <div className="new-item has-bottom-padding">
        <form action="/items" acceptCharset="UTF-8" method="post">
          <input name="utf8" type="hidden" value="✓" />
          <input type="hidden" name="authenticity_token" value="YKd0dbDQmmzUiqJevXRBF6XpXAMMk2OZ+iYFy3cf4MzkRAftVTxesYMkPg62a5jHbbqrnkg7Mns3cURcPK/kZg==" />
          <p className="control has-addons">
            <input value={this.state.search} onChange={this.onChange} className="input is-expanded is-medium filter scraper-query" placeholder="Search" autoComplete="off" type="text" name="item[name]" id="item_name" />
          </p>
        </form>
      </div>
    )
  }
}