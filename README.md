# Lists

![Build status](https://travis-ci.org/rathrio/lists.svg?branch=master)

![Screenshot](https://i.imgur.com/w5QObdq.png)

Smart lists to keep track of media to consume.

## Prerequisites

+ [Ruby >= 2.5](https://www.ruby-lang.org/en/documentation/installation/)
+ [Bundler](https://bundler.io/)
+ [PostgreSQL](https://www.postgresql.org/)
+ [Redis](https://redis.io/)
+ [Imagemagick >= 7](https://www.imagemagick.org/script/index.php)
+ [Yarn](https://yarnpkg.com/en/docs/install)

Make sure postgres and redis servers are running.

## Installation

1. Install dependencies:
    ```
    bundle install
    yarn install
    ```

2. Setup database:
    ```
    ./bin/rails db:setup
    ```

3. Apply migrations:
    ```
    ./bin/rails db:migrate
    ```

## Running

1. Run sidekiq for background jobs:
    ```
    ./bin/sidekiq -C config/sidekiq.yml
    ```

2. Run the application server:
    ```
    foreman start -f Procfile.dev-server
    ```

## Running tests

```
./bin/rails test
```

## Generate Documentation

```
./bin/rails docs
```

## Contributing

1. Fork this repository
2. Create your feature branch `git checkout -b my-new-feature`
3. Commit your changes `git commit -am "Add some feature"`
4. Push to the branch `git push origin my-new-feature`
5. Run tests
    ```
    ./bin/rails test
    ```

6. Review changes and fix style
    ```
    ./bin/pronto run
    ```

5. Create new Pull Request (in your forked repository)
