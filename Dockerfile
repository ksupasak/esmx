FROM ruby:3.1.7

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libmariadb-dev \
  nodejs \
  wkhtmltopdf \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install bundler -v '~> 2.6'

COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .

RUN chmod +x docker-entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
