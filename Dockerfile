# Use Ruby 2.7.5-bullseye as the base image (newer than buster)
FROM ruby:2.7.5-bullseye

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    postgresql-client \
    sqlite3 \
    libsqlite3-dev \
    pkg-config \
    libxml2-dev \
    libxslt1-dev

# Install yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install specific bundler version
RUN gem install bundler:2.4.22

# Configure bundler to use ruby platform for nokogiri
RUN bundle config set force_ruby_platform true

# Install gems with specific platform for nokogiri
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the application
COPY . .

# Add a script to be executed every time the container starts
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]
