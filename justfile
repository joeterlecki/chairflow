# Run `just` with no arguments to list recipes.
default:
    @just --list

# Build (or rebuild, after a Gemfile change) the dev image.
build:
    docker compose build

# Start the dev server (Rails + Tailwind watcher) at http://localhost:3000, detached.
up:
    docker compose up -d
    @echo "Chairflow running at http://localhost:3000"

# Follow the dev server's logs.
logs:
    docker compose logs -f web

# Stop the dev server.
down:
    docker compose down

# Everything: setup, rubocop, security audits, and the full test suite (including system tests).
# Mirrors bin/ci (config/ci.rb); run this before considering a task done.
ci:
    docker compose run --rm web bin/ci

# Run the test suite (unit, integration, and system tests).
test:
    docker compose run --rm web bin/rails test:all

# Rubocop (rubocop-rails-omakase).
lint:
    docker compose run --rm web bin/rubocop

# Brakeman static security analysis.
security:
    docker compose run --rm web bin/brakeman --no-pager

# Rails console inside the dev container.
console:
    docker compose run --rm web bin/rails console

# A shell inside the dev container.
sh:
    docker compose run --rm web bash

# Prepare the database (migrate + seed) without starting a server.
setup:
    docker compose run --rm web bin/setup --skip-server
