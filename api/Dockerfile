FROM ruby:3-alpine

RUN apk update
RUN apk add --update build-base gcompat postgresql-dev tzdata imagemagick imagemagick-libs libjpeg-turbo yaml-dev

WORKDIR /lists

COPY Gemfile /lists/Gemfile
COPY Gemfile.lock /lists/Gemfile.lock

RUN bundle install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

COPY . .

# https://github.com/rails/mission_control-jobs?tab=readme-ov-file#api-only-apps-or-apps-using-vite_rails-and-other-asset-pipelines-outside-rails
# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma_production.rb"]
