FROM ruby:2.6-stretch

RUN apt-get update
RUN apt-get install -y curl software-properties-common

# Install node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
      apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
      apt update && apt install -y yarn

COPY . /app
WORKDIR /app

RUN bundle install && yarn install

CMD ["bash"]
