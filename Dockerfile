FROM ruby:3.1.0

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libmariadb-dev \
  nodejs \
  wkhtmltopdf \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
