# Lists ![Build status](https://travis-ci.org/rathrio/lists.svg?branch=master)

![Screenshot](https://i.imgur.com/L0kJMyc.png)

Smart lists to keep track of media to consume.

## Prerequisites

+ [Ruby 2.4.0](https://www.ruby-lang.org/en/documentation/installation/)
+ [Bundler](https://bundler.io/)
+ [PostgreSQL](https://www.postgresql.org/)
+ [Redis](https://redis.io/)
+ [Imagemagick](https://www.imagemagick.org/script/index.php)

Make sure postgres and redis servers are running.

## Installation

1. Install dependencies:
    ```
    bundle install
    ```

2. Setup database:
    ```
    bundle exec rake db:setup
    ```

3. Apply migrations:
    ```
    bundle exec rake db:migrate
    ```

## Running

1. Run sidekiq for background jobs:
    ```
    bundle exec sidekiq -C config/sidekiq.yml
    ```

2. Run the application server:
    ```
    bundle exec rails server
    ```

## Running tests

```
bundle exec rake test
```

## Generate Documentation

```
bundle exec rake docs
```

## Contributing

1. Fork this repository
2. Create your feature branch `git checkout -b my-new-feature`
3. Commit your changes `git commit -am "Add some feature"`
4. Push to the branch `git push origin my-new-feature`
5. Run tests
    ```
    bundle exec rake
    ```

6. Review changes and fix style
    ```
    bundle exec rake review
    ```

5. Create new Pull Request (in your forked repository)
