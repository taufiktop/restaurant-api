#!/bin/bash
set -e

# Wait for database to be ready (now on port 5432)
wait-for-it db:5432 --timeout=30 --strict -- echo "Database is up"

# Create, migrate, and seed database
bundle exec rails db:create db:migrate db:seed

# Reindex Elasticsearch
bundle exec rails searchkick:reindex:all

exec "$@"
