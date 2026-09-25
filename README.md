# Chairflow

Rails 8.1 / Ruby 3.4.11 salon scheduler using SQLite, Hotwire, import maps, and Tailwind v4.

## Local development

Requires Ruby/Bundler. Export `ADMIN_PASSWORD` before seeding a fresh database; Rails does not automatically load `.env`.

```sh
bundle install
bin/rails db:prepare db:seed
bin/dev
```

Open **http://localhost:3000**. Sign in as **admin** with the password used for the first seed. Rerunning seeds does not reset it. Tailwind is the only app asset build; Node is only needed for browser tests.

## Docker

Requires Docker Compose and [just](https://just.systems). Create `.env` from `.env.example`, set `ADMIN_PASSWORD`, and provide the matching `config/master.key` for the encrypted Rails credentials.

```sh
just up        # Build, start in background, wait for health check
just run       # Build and run in foreground
just down      # Stop; preserve database volume
just logs      # Follow logs
just seed      # Populate repeatable demo data
just console   # Rails console
just           # List all recipes
```

- Startup runs `db:prepare`. Rebuild with `just up` after code changes; use `bin/dev` for live development.
- Container data lives in `salon-week_salon_storage`, separate from native development data. `docker compose down --volumes` deletes it.
- `.env`, decryption keys, databases, and generated artifacts are Git-ignored.
- Default salon zone: `America/New_York`. Override `SALON_TIME_ZONE`; Compose also accepts `PORT`, e.g. `PORT=3001 just up`.

## Checks

```sh
bin/rails test
bin/rubocop
bin/brakeman --no-pager
bin/rails tailwindcss:build
```

Browser tests additionally require Node.js 22+:

```sh
just browser-install
just browser-test
npm run test:e2e:ui
```

Playwright starts an isolated Rails server on **127.0.0.1:3100** and resets only `storage/playwright.sqlite3`. Keep that port free. View failure screenshots/traces with `npx playwright show-report`.

## Spec-driven development

Spec Kit **1.0.11** is installed for OpenCode. Restart OpenCode after installing/updating its commands.

- **[SPEC.md](SPEC.md):** living product baseline and stable requirement IDs.
- **[Development rules](.specify/memory/constitution.md):** Spec Kit's “constitution”—shared rules for agents and contributors; still a review draft.
- **[AGENTS.md](AGENTS.md):** agent entry point.
- **[specs/README.md](specs/README.md):** artifact lifecycle and adoption decisions.

Use these commands **in OpenCode chat**, one stage at a time:

```text
/speckit.specify <one bounded change; reference relevant CF-* requirements>
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.analyze
/speckit.implement
/speckit.converge
```

Clarify open questions before planning, review artifacts before implementation, and verify acceptance criteria at completion. Each feature lives in `specs/NNN-feature-name/` with `spec.md`, `plan.md`, and `tasks.md`. Update the baseline as features ship; keep completed feature artifacts as delivery history and use a new feature for later changes.

**Likely first feature: client history.** Its scope still needs clarification before planning. Product behavior and roadmap detail belong in the specs, not this README.

## Sentry

Compose supplies the project DSN. Use `just sentry-check` to send tagged verification events. Defaults: environment `local-docker`, release `chairflow@poc`, trace/profile sample rates `1.0`. Override `SENTRY_ENVIRONMENT`, `SENTRY_RELEASE`, `SENTRY_TRACES_SAMPLE_RATE`, and `SENTRY_PROFILES_SAMPLE_RATE` as needed; an empty `SENTRY_DSN` disables sending. Native development requires exporting a DSN. Tests and asset builds send no telemetry.

OpenCode's project-scoped Sentry MCP connection is in `opencode.json`; authenticate with `opencode mcp auth sentry`. SDK delivery and account-side issue lookup are separate checks. See [SPEC.md](SPEC.md) for the observability contract.
