#!/bin/sh

set -e

bundle exec rails db:create db:migrate

exec "$@"