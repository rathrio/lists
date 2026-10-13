# Lists

![Screenshot](./screenshots/2023-03-ipad-iphone.png)

App that keeps track of movies, TV shows, games, books and various other things.
This project exists because I'd rather manage these in one self-hosted location
instead of multiple third-party services, such as Letterboxd, Goodreads or the
Steam Library.

## Prerequisites

API:
   - [Ruby >= 2.6](https://www.ruby-lang.org/en/documentation/installation/)
   - [Bundler](https://bundler.io/)
   - [PostgreSQL >= 13](https://www.postgresql.org/)
   - [Redis](https://redis.io/)
   - [Imagemagick >= 7](https://www.imagemagick.org/script/index.php)

UI:
   - [Node >= 22](https://nodejs.org/en/)

Ensure that postgres and redis servers are running (listening to default ports).

## Installation

API (`cd api`):

   1. Install dependencies:
       ```bash
       bundle install
       ```

   2. Setup database:
       ```bash
       ./bin/rails db:setup
       ```

   3. Apply migrations:
       ```bash
       ./bin/rails db:migrate
       ```

UI (`cd ui`):

   1. Install dependencies:
      ```bash
      npm install
      ```

## Running

API (`cd api`):

```bash
brew services start postgresql@14
brew services start redis
./bin/rails server
```

UI (`cd ui`):

```bash
npm run dev
```

Then visit http://localhost:3001.

## Running tests

API (`cd api`):

```bash
./bin/rails test
```

UI (`cd ui`):

```bash
npm run test
```

## OPS

The top level directory contains some convenience scripts to help with deploying
and spawning remote shells.

- `deploy`: Builds and deploys backend and frontend to lists.rathr.io
- `redis`: Spawns a `redis-cli` in the redis container
- `postgres`: Spawns a `psql` shell in the postgres container
- `web`: Spawns a shell in the web container

## MCP server

The API exposes a read-only [MCP](https://modelcontextprotocol.io) endpoint at
`/mcp` (`https://lists.rathr.io/api/mcp` in production) so that clients such as
Claude Desktop can search lists, read the journal, compute stats and check
Jellyfin availability on behalf of a user.

Requests authenticate with a per-user bearer token. Only its digest is stored,
so it's shown once on generation; generating a new one revokes the old one:

```sh
bin/rails 'api_token:generate[me@example.com]'
bin/rails 'api_token:revoke[me@example.com]'
```

Claude Desktop (`~/Library/Application Support/Claude/claude_desktop_config.json`)
connects through [`mcp-remote`](https://www.npmjs.com/package/mcp-remote):

```json
{
  "mcpServers": {
    "lists": {
      "command": "npx",
      "args": [
        "-y", "mcp-remote", "https://lists.rathr.io/api/mcp",
        "--header", "Authorization: Bearer ${LISTS_API_TOKEN}"
      ],
      "env": { "LISTS_API_TOKEN": "lists_..." }
    }
  }
}
```

## APIs used

Lists relies on the following APIs to scrape meta info:

- Movies / TV Shows: [The Movie DB](https://www.themoviedb.org)
   - https://developer.themoviedb.org/reference/intro/getting-started
- Video Games: [IGDB](https://www.igdb.com/discover)
- Books: [Google Books](https://developers.google.com/books)
- Recipes: [Edaman](https://www.edamam.com)
