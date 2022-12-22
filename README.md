# Lists

![Screenshot](https://i.imgur.com/FjAIctw.png)

Lists to keep track of movies, TV shows, games, books and various other things.
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
   - [Node >= 16](https://nodejs.org/en/)
   - [Yarn](https://yarnpkg.com/en/docs/install)

Ensure that postgres and redis servers are running (listening to default ports).

## Installation

API (`cd api`):

   1. Install dependencies:
       ```bash
       bundle install
       yarn install
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
      yarn install
      ```

## Running

API (`cd api`):

```bash
./bin/rails server
```

UI (`cd ui`):

```bash
yarn start
```

Then visit http://localhost:3001.

## Running tests

API (`cd api`):

```bash
./bin/rails test
```

UI (`cd ui`):

```bash
yarn test
```

## Contributing

1. Fork this repository
2. Create your feature branch `git checkout -b my-new-feature`
3. Commit your changes `git commit -am "Add some feature"`
4. Push to the branch `git push origin my-new-feature`
5. Run tests
    ```bash
    # in api/
    ./bin/rails test

    # in ui/
    yarn test
    ```

6. Create new Pull Request (in your forked repository)

## API Credits

Lists relies on the following APIs to scrape meta info:

- Movies / TV Shows: [The Movie DB](https://www.themoviedb.org)
- Video Games: [IGDB](https://www.igdb.com/discover)
- Books: [Google Books](https://developers.google.com/books)
- Recipes: [Edaman](https://www.edamam.com)
