FROM ruby:3.1.7

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libmariadb-dev \
  nodejs \
  wkhtmltopdf \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install bundler -v '~> 2.6'

COPY Gemfile ./
RUN bundle lock --update && bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
