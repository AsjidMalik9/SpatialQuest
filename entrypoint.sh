#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Run database migrations
bundle exec rails db:migrate

# Seed the database
bundle exec rails db:seed

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@" 