# Show available commands.
default:
    @just --list

# Build the Rails image, including Tailwind assets.
build:
    docker compose build

# Build and run in the foreground (Ctrl-C to stop).
run:
    docker compose up --build

# Build and start in the background; wait until healthy.
up:
    docker compose up --build --detach --wait

# Stop and remove containers; keep the SQLite volume.
down:
    docker compose down

# Follow application logs.
logs:
    docker compose logs --follow web

# Show container health and port mappings.
status:
    docker compose ps

# Add repeatable demo data to the running app.
seed:
    docker compose exec web bin/rails db:seed

# Open a Rails console in the running app.
console:
    docker compose exec web bin/rails console

# Run a Rails command in the running app, e.g. just rails routes.
rails +args:
    docker compose exec web bin/rails {{args}}

# Install browser-test dependencies and Chromium (host Node and Ruby required).
browser-install:
    npm ci
    npx playwright install chromium

# Run isolated browser tests against a temporary Rails test server.
browser-test:
    npm run test:e2e

# Send an identifiable Sentry verification from the running Rails container.
sentry-check:
    docker compose exec web bin/rails sentry:verify
