FROM ruby:3-alpine

RUN apk add --update build-base gcompat postgresql-dev tzdata imagemagick

WORKDIR /lists

COPY Gemfile /lists/Gemfile
COPY Gemfile.lock /lists/Gemfile.lock

RUN bundle install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma_production.rb"]
