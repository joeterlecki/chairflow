# Chairflow — product and development baseline

**Specification:** CF-BASELINE · **Revision:** 0.3 · **Status:** Draft for review

**Recorded:** 2026-09-25 · **Scope:** Current single-salon Rails POC

## 1. Purpose and how to use this document

This is the shared baseline for product conversations, implementation, and agent handoffs. It records what Chairflow does today and the development principles established while building it.

The baseline describes the **current working tree**, including Chairflow branding and the booking-details modal. The initial commit is `41b5426`; those later refinements were not part of that commit. This document does not imply they have since been committed or deployed publicly.

- **Implemented** means the behavior exists in the current code, not that it has been proven at production scale.
- **Standard** describes a convention to preserve in future changes unless explicitly revised.
- **Proposed** means discussed but not authorized for implementation by this document.
- Requirement IDs are stable conversation references. Cite them in change specs and verification summaries; retain IDs when wording evolves.
- `README.md` owns setup commands and operational instructions. This file owns product intent, behavior contracts, boundaries, and the change process.
- Spec Kit is initialized for this existing project. Its draft constitution lives in `.specify/memory/constitution.md`; future bounded changes use `specs/NNN-feature-name/spec.md`, `plan.md`, and `tasks.md`. See `specs/README.md` for adoption status and open decisions.
- Code and tests are evidence of actual behavior. If they disagree with this spec, identify the discrepancy and resolve it in the change; do not silently redefine the intended behavior.
- This first draft is a reviewable baseline, not blanket approval for the roadmap in section 8.

## 2. Product intent and scope

### CF-PRODUCT-001 — Purpose · Implemented

Chairflow helps a small salon or independent stylist arrange appointments, understand team coverage, and keep client information close to the booking workflow. Prioritize a calm, useful working-day experience that one developer can maintain.

### CF-PRODUCT-002 — Brand · Standard

- Product: **Chairflow**; wordmark: **chairflow**; mark: **c.**
- Tagline: **Your salon, in rhythm.**
- Planned marketing domain: `chairflow.studio`.
- Planned application domain: `app.chairflow.studio`; sign-in path: `/login`.
- The current application runs locally through Rails or Docker. Marketing pages, public hosting, DNS, and TLS provisioning are not implemented here.

### CF-PRODUCT-003 — Operating model · Implemented

- One salon, one configured salon time zone, and a staff-managed appointment book.
- A seeded admin account has access to all salon screens. There is no role/permission system or user-to-stylist account relationship.
- An appointment reserves one continuous interval for one client and one stylist.
- A stylist is a schedulable team member; a `User` is a login account. Keep those concepts distinct.

### CF-PRODUCT-004 — Scope boundary · Standard

Team management means **coverage and availability planning**. Payroll, time clocks, HR records, commissions, and workforce-management features are outside the agreed direction. Avoid expanding a small scheduling request into those features.

## 3. User experience and design language

### CF-UX-001 — Visual language · Standard

- Warm off-white canvas (`#f7f6f2`), white panels, subtle stone borders, soft shadows, and generous spacing.
- Sage-green primary actions (`#344d42`); muted sage, clay, lavender, and blue stylist colors.
- Rounded panels/buttons, restrained typography, small uppercase section labels, and clear hierarchy.
- Friendly, concise copy. Descriptions of scheduling conflicts must say what needs to change.
- Reuse the components and styles in `app/assets/tailwind/application.css` before inventing a new design vocabulary.
- Stylist color supports recognition; names, times, and text also communicate meaning.

### CF-UX-002 — Inspect before changing · Implemented

Clicking an existing calendar booking opens **read-only details**, not the edit form. Editing is an explicit action. The existing dedicated edit screen remains the place to change or cancel an appointment.

### CF-UX-003 — Context and accessibility · Standard

- Preserve the relevant date/view/filter when navigating between calendar and booking screens.
- Dismissing booking details preserves the calendar URL and scroll position.
- Use labeled inputs, accessible controls, visible focus, inline validation errors, and status messages.
- Dialogs support keyboard use, focus containment, Escape dismissal, and focus restoration.
- On smaller screens, contain calendar/table overflow within the component. Forms and modal actions must remain usable without horizontal page scrolling.
- Provide ordinary links and server-rendered fallbacks where supported; interactive enhancements belong in small Stimulus controllers.

## 4. Functional baseline

### 4.1 Access

| ID | Implemented behavior |
| --- | --- |
| CF-AUTH-001 | `/login` provides a styled username/password form. Salon data routes require authentication; `/up` remains public for health checks. |
| CF-AUTH-002 | Passwords use bcrypt via `has_secure_password`. Login resets the session; sessions expire after 12 hours. Sign-out clears the session. |
| CF-AUTH-003 | Successful login returns to the requested eligible page. Invalid credentials return a generic error without repopulating the password. |
| CF-AUTH-004 | Login is limited to 10 attempts per IP per 3 minutes through the Rails cache-backed rate limiter. Authenticated responses use `no-store`; Turbo snapshots are disabled. |
| CF-AUTH-005 | Seeds create `admin` only when absent, using `ADMIN_PASSWORD`. Subsequent seeds do not reset an existing password. Real credentials stay outside tracked source. |

### 4.2 Appointment calendar

| ID | Implemented behavior |
| --- | --- |
| CF-CAL-001 | Day and Monday–Sunday Week views support previous/next navigation, Today, and Everyone/individual-stylist filtering. Clicking a date opens Day view. |
| CF-CAL-002 | Days share a vertical time axis. Each day has consistent stylist lanes; simultaneous bookings align horizontally, and card height represents duration. |
| CF-CAL-003 | The grid has a bounded scrolling viewport, sticky date/stylist headers, and a sticky time gutter. More appointments do not create a longer stack of cards. |
| CF-CAL-004 | Off-hours and breaks are shaded; time off is labeled. The displayed time range includes visible schedules and existing bookings, including legacy bookings outside current coverage. |
| CF-CAL-005 | Clicking an open slot prefills stylist/date/time. If the default service duration cannot fit, it selects a shorter supported duration that fits. Users can change service/duration in the form. |
| CF-CAL-006 | On screens narrower than 768px, an unspecified view defaults to Day through Stimulus. An explicit Week selection is respected and scrolls horizontally inside the grid. |

The current display scale is 1.6 pixels per minute (`CalendarGrid::PIXELS_PER_MINUTE`). That is a tunable presentation choice; accurate time alignment and relative duration are the contract.

### 4.3 Booking details, creation, editing, and cancellation

| ID | Implemented behavior |
| --- | --- |
| CF-BOOK-001 | Calendar cards load a read-only details modal through Turbo. It shows client, service, date, start/end, duration, salon time zone, assigned stylist, preferred stylist, contact details, and visit notes. |
| CF-BOOK-002 | The modal closes with Done, the close button, Escape, or outside-click. Focus returns to the booking. Edit appointment opens the existing edit screen with calendar context. A direct appointment URL renders a full read-only page, including without JavaScript. |
| CF-BOOK-003 | A booking requires a client, stylist, valid service name, start time, and supported duration. Optional visit notes are limited to 2,000 characters. End time is calculated from start plus duration. |
| CF-BOOK-004 | Supported durations are 15, 30, 45, 60, 90, 120, and 180 minutes. Appointments must start and end on the same salon-local date. Overnight appointments are rejected. |
| CF-BOOK-005 | Creating, moving, changing duration, or reassigning a booking checks current coverage and stylist overlaps on the server. An edit excludes itself from overlap checks. |
| CF-BOOK-006 | The form’s live day planner responds to stylist/date/time/duration changes, shows existing bookings and conflicts, and offers selectable open start times. Its day arrows retain other form input. |
| CF-BOOK-007 | A new client may be created inline. A supplied new name overrides the existing-client selection; invalid client or booking data prevents both records from being saved. |
| CF-BOOK-008 | Validation errors retain entered form values and return HTTP 422. Successful mutations redirect back to the appropriate calendar view. |
| CF-BOOK-009 | **Current cancellation behavior is deletion**, with confirmation on the edit screen. There are no appointment statuses, retained cancellation records, or audit history yet. |
| CF-BOOK-010 | Notes-only edits to legacy bookings outside current coverage remain possible. Changes to time, duration, or stylist recheck coverage; ordinary model validations still apply. |

Appointments use half-open intervals: `[start, end)`. An existing booking conflicts when `existing.start < requested.end` and `existing.end > requested.start`. Back-to-back appointments are allowed, as are simultaneous bookings for different stylists.

Manual times are not restricted to quarter-hour boundaries. Suggested slots use 15-minute increments and must fit the entire selected duration.

### 4.4 Team coverage

| ID | Implemented behavior |
| --- | --- |
| CF-TEAM-001 | Team schedule shows employees as rows and dates as columns, with week navigation, shift/break details, booking counts, and daily/weekly coverage totals excluding breaks. |
| CF-TEAM-002 | Recurring `WorkingDay` records define the usual week. Each date supports one continuous shift and one optional break, or a day off. Both break endpoints are required together and must be ordered within working hours. |
| CF-TEAM-003 | Clicking a cell edits one date through a `ScheduledShift`; it does not rewrite future weekdays. Removing the dated shift restores recurring hours after checking affected bookings. |
| CF-TEAM-004 | `TimeOff` blocks an inclusive date range for one stylist, with an optional note of up to 200 characters. Reversed ranges and overlapping time-off records for the same stylist are rejected. |
| CF-TEAM-005 | Effective coverage is resolved by `Stylist#schedule_for(date)`: **time off → dated shift → recurring hours**. The appointment calendar, day planner, and booking validation use this precedence. |
| CF-TEAM-006 | Dated shift changes and time off reject conflicts with appointments on the affected dates. Recurring-hours changes check future appointments not covered by dated overrides. No affected appointments are automatically moved or cancelled. |
| CF-TEAM-007 | A rejected schedule change shows links to bookings needing attention and persists no partial schedule update. Reverting a dated shift is also rejected if recurring hours would strand an existing booking. |
| CF-TEAM-008 | Removing time off restores the dated shift or recurring hours underneath. Legacy bookings outside effective coverage are flagged in the team planner. |

Coverage hours are the sum of working time across employees, excluding breaks. They are not a demand forecast or a promise that every moment of the day is staffed.

### 4.5 Services

| ID | Implemented behavior |
| --- | --- |
| CF-SVC-001 | Service names are seeded/catalog-managed; the Services UI edits default durations. Defaults must use a supported appointment duration. |
| CF-SVC-002 | Changing service in the booking form applies its default and refreshes availability. A user can override duration for that visit. Editing service defaults or opening an existing booking does not resize existing bookings. |
| CF-SVC-003 | Initial defaults: Cut & finish 60m; Color & cut 120m; Blowout 30m; Highlights 180m; Consultation 15m. Cut & finish is the initial booking service when present. |

### 4.6 Clients

| ID | Implemented behavior |
| --- | --- |
| CF-CLIENT-001 | The client directory supports creation, editing, and search by name/email/phone. Name is required and limited to 100 characters; email and phone are optional. |
| CF-CLIENT-002 | Names/phones are trimmed, emails are trimmed/lowercased, and blank contacts become null. Email/phone format and length are validated. Contact values are not unique: shared details are allowed. |
| CF-CLIENT-003 | Preferred stylist is an optional association; null means **No preference**. This is not a restriction on whom the client may book with. |
| CF-CLIENT-004 | A client created during booking defaults to that appointment’s stylist unless another preference or No preference is explicitly selected. A client created in the directory defaults to No preference. |
| CF-CLIENT-005 | Later bookings do not overwrite a client’s saved preference, including explicit No preference. The client editor can change or clear it. |
| CF-CLIENT-006 | Contact information is groundwork only: no reminder preference, consent record, verification state, reminder job, or email/SMS delivery workflow exists yet. |

## 5. Data and architecture

### 5.1 Persistence map · Implemented

`db/schema.rb` is the current database reference. All records also have IDs/timestamps.

| Model | Main persisted fields / relationship |
| --- | --- |
| `User` | Unique username, password digest; no role column or stylist association. |
| `Stylist` | Name and palette color; schedules and appointments belong to the stylist. |
| `Client` | Name, optional email/phone, optional `preferred_stylist_id`. |
| `Service` | Unique name and default duration. |
| `Appointment` | Client/stylist foreign keys, **service-name string**, start/end timestamps, optional notes. Duration is calculated/virtual, not a separate column. |
| `WorkingDay` | Stylist, weekday 0–6 (Sunday = 0), closed flag, local `HH:MM` start/end and optional break; unique per stylist/weekday. |
| `ScheduledShift` | Stylist, date, the same hours/break fields; unique per stylist/date. |
| `TimeOff` | Stylist, inclusive start/end dates, optional note. |

Database constraints include foreign keys, uniqueness for schedule keys/usernames/service names, positive appointment duration, and ordered time-off dates. They do not currently enforce appointment interval exclusion.

Do not silently convert `Appointment#service` into a `Service` association or introduce statuses/reminders without a migration and a scoped feature spec. Preserve existing bookings and preferences during schema changes.

### CF-ARCH-001 — Rails-first implementation · Standard

- Baseline: Ruby 3.4.11 / Rails 8.1.4, SQLite, Active Record, ERB, Hotwire/Turbo, Stimulus, import maps, Propshaft, and Tailwind v4. Lockfiles are authoritative for installed versions.
- Prefer conventional Rails controllers, partials, models, and small plain-Ruby objects. Introduce abstractions where they remove actual duplication or clarify domain rules.
- Keep scheduling calculations and validation in Ruby; JavaScript coordinates UI behavior rather than owning a second set of business rules.
- Tailwind is the only application asset build. Node/npm are for Playwright tooling, not an application bundler or SPA.
- No third-party calendar library is installed. The calendar uses CSS Grid and custom Ruby geometry.

### CF-ARCH-002 — Responsibility map · Implemented

| Location | Responsibility |
| --- | --- |
| `app/models/appointment.rb` | Booking validation, duration/end-time calculation, and fresh coverage checks at save. |
| `app/models/stylist.rb` | Effective schedule resolution and associations. |
| `app/models/concerns/schedule_hours.rb` | Shared working-hours/break rules. |
| `app/models/concerns/protects_bookings.rb` | Shared reporting of schedule conflicts. |
| `app/models/day_availability.rb` | Booking-form conflicts and suggested times. |
| `app/models/calendar_grid.rb` | Calendar geometry and clickable slot generation. |
| `app/controllers/*` | Request loading, `params.expect` strong parameters, rendering, and redirects. |
| `app/views/calendar/`, `app/views/appointments/`, `app/views/stylists/` | Calendar, booking/details, and team planner rendering. |
| `app/javascript/controllers/` | Small interaction controllers: availability updates, mobile calendar default, dialog lifecycle/focus. |

`DayAvailability` and `CalendarGrid` still have separate slot-generation paths. Shared hours rules exist, but fully consolidated availability generation is a future refactor, not a completed abstraction.

### CF-TIME-001 — Date and time semantics · Standard

- Use Rails `Time.zone` / Active Support and TZInfo; do not depend on the browser or server machine’s local zone for salon logic.
- `SALON_TIME_ZONE` defaults to `America/New_York`; there is no per-salon/per-client zone selector.
- Store appointment timestamps in UTC. Interpret form input and display in the salon zone.
- Store recurring/dated shift hours as local clock strings; combine them with the relevant date through `Time.zone.local`.
- Time off uses calendar dates, not UTC-midnight intervals supplied by the browser.
- Daylight-saving transitions and a policy for changing the salon zone after bookings exist have not been comprehensively specified/tested. A feature involving either must define its behavior explicitly.

### CF-OPS-001 — Local runtime and data · Standard

- Docker uses a non-root Rails image with precompiled assets, a persistent SQLite volume, and `/up` health checks. Startup runs `db:prepare`.
- Compose currently serves localhost over HTTP. Follow `README.md` for native and container setup; do not equate the Rails production environment with a public production deployment.
- Keep `.env`, Rails decryption keys, databases, logs, PID files, compiled assets, `node_modules`, and browser artifacts ignored. Track migrations, schema, lockfiles, and the empty environment template.
- Demo seeds are additive and repeatable: preserve existing bookings, preferences, and customized schedules. Demo identities use fictional contact details. Current seeded stylists are Melissa, Zoe, and Lauren.
- Keep existing internal names such as Rails `SalonWeek`, Compose `salon-week`, and its volume unless a migration explicitly addresses them. A product rename must not accidentally create an empty database volume.

### CF-OBS-001 — Observability · Implemented

- Sentry Ruby/Rails 7.x, StackProf loaded first, one initializer, errors, Rails/HTTP breadcrumbs, log forwarding, tracing, and profiling.
- Current POC defaults sample all traces/profiles except health-check transactions. Environment/release/rates are configurable; Docker is tagged `local-docker` with default release `chairflow@poc`.
- Tests and asset builds have no Sentry DSN. Preserve Rails/Sentry filtering and do not add credentials to logs, spans, or docs.
- Sentry project remains `joes-testing/ruby-poc`; OpenCode MCP is project-scoped in `opencode.json` and requires the developer’s separate OAuth authorization.
- `just sentry-check` intentionally sends verification events. Distinguish those from product failures, and report whether verification means transport acceptance or confirmed indexed data.
- No AI model/agent/chat workflow exists in the salon app; AI Conversations instrumentation is not implemented.

## 6. Baseline acceptance scenarios and evidence

These scenarios anchor future regression checks. The test files are evidence to inspect and extend, not a promise that every possible edge case is covered.

| Scenario | Expected result | Requirements | Existing evidence |
| --- | --- | --- | --- |
| Guest opens a salon data route | Login required; expired frame navigation reaches the full login screen. | CF-AUTH-001–004 | `test/integration/authentication_test.rb`, `test/browser/authentication.spec.js` |
| Two stylists have appointments at 10am | Cards align vertically at 10am in separate lanes; twice the duration has twice the height. | CF-CAL-002–003 | `test/browser/calendar.spec.js` |
| User clicks a booking, then closes details | Read-only modal; no navigation or mutation; focus and calendar scroll restored. | CF-BOOK-001–002 | `test/integration/appointment_details_test.rb`, `test/browser/booking_details.spec.js` |
| Existing booking ends at 11am; another starts at 11am | Allowed for that stylist; an overlapping interval is rejected. | CF-BOOK-005 | `test/models/appointment_test.rb` |
| Client books around a lunch break | Full appointment must fit; 11–12 is allowed for a 12–13 break, 11:30–12:30 is not. | CF-BOOK-005–006, CF-TEAM-002 | `test/models/working_day_test.rb`, `test/integration/availability_test.rb` |
| One Monday’s shift changes | That date uses the override; the next Monday uses recurring hours; time off takes priority. | CF-TEAM-003–005 | `test/integration/team_schedule_test.rb`, `test/browser/team_schedule.spec.js` |
| A proposed shift/time-off change conflicts with a booking | Reject the change with affected-booking links; reverting a shift cannot strand a booking either. | CF-TEAM-006–007 | `test/integration/team_schedule_test.rb` |
| Client explicitly chooses No preference and books again | Preference stays null; the later stylist does not silently replace it. | CF-CLIENT-003–005 | `test/integration/client_preferences_test.rb` |
| Service default changes after a booking exists | The booking keeps its saved duration; new service selection uses the new default. | CF-SVC-002 | `test/integration/salon_settings_test.rb`, `test/browser/scheduling.spec.js` |
| Seeds rerun for the same week | Existing records/customizations are preserved and bookings are not duplicated. | CF-OPS-001 | `test/integration/demo_seeds_test.rb` |

## 7. Spec-driven development workflow

### CF-DEV-001 — Before implementation · Standard

1. Read this baseline, `README.md`, and the relevant code/tests. Check the working tree for existing user work.
2. Restate the requested outcome, identify affected requirement IDs, and classify it as a bug fix, behavior change, or new capability.
3. For a behavior change, use `/speckit.specify` to write a bounded change spec **before coding**, at `specs/NNN-feature-name/spec.md`. Reference this baseline rather than respecifying the entire existing app. Keep small baseline/documentation clarifications lightweight.
4. State scope, exclusions, data impact, acceptance criteria, and unresolved choices. Ask about material product decisions; do not invent them.
5. An explicit, scoped user request can authorize implementation. Do not require a second approval for an already-decided task. Unresolved proposals stay Proposed until decided.

### CF-DEV-002 — During implementation · Standard

- Build the smallest end-to-end change satisfying the acceptance criteria; preserve existing design and behavior outside that scope.
- Enforce business rules on the server and preserve data through migrations. Avoid blanket data resets or broad refactors disguised as feature work.
- Keep related code, migrations, tests, and documentation consistent in the same change.
- If a new tradeoff or constraint changes the intended behavior, record it in the spec and surface it before expanding scope.
- Future ideas are not dependencies unless the approved change explicitly needs them.

### CF-DEV-003 — Verification and completion · Standard

Choose checks according to the change, using existing project tooling:

| Change | Verification |
| --- | --- |
| Model, scheduling, controller, or persistence behavior | Relevant Rails tests; migrations on an isolated/test database when applicable. |
| Turbo/Stimulus, navigation, modal, or important UI flow | Relevant Playwright scenarios; desktop/mobile visual inspection when layout changes. |
| Ruby code | RuboCop on affected code; Brakeman for authentication/security-sensitive changes. |
| CSS/assets | Tailwind build; inspect the affected rendered screens. |
| Container/runtime | Compose config validation and a healthy boot; rebuild the local app when delivery requires it. |
| Documentation-only | Review factual accuracy, references, and diff formatting; no app rebuild or artificial tests required. |

- Commands: `bin/rails test`, `bin/rubocop`, `bin/brakeman --no-pager`, `bin/rails tailwindcss:build`, `just browser-test`, and `just up`. See `justfile`/README for prerequisites.
- GitHub CI additionally runs gem and import-map vulnerability audits. Playwright uses a dedicated test database and port 3100; it must not reset development or Docker data.
- Add meaningful regression/acceptance tests for changed behavior. Avoid tests that merely duplicate implementation or tests for trivial copy-only edits.
- Report what was checked, results, and any unverified/blocked criteria. Do not claim browser verification from controller tests alone, or Sentry ingestion from configuration alone.
- Mark a feature Implemented only after its scoped acceptance criteria are met; document partial completion explicitly.
- Commit, push, deploy remotely, or change Sentry issue status only when requested. When committing, use Conventional Commits, review the diff, and keep credentials/generated artifacts out of history.

### Spec Kit artifact framework

The installed framework replaces the initial custom change-spec template. The pre-adoption draft is preserved in the local backup documented in `backups/README.md`.

| Artifact | Purpose |
| --- | --- |
| `.specify/memory/constitution.md` | Cross-feature principles and quality gates, currently a review draft. |
| `.specify/templates/spec-template.md` | Source template for prioritized user stories, Given/When/Then scenarios, functional requirements, success criteria, and assumptions. |
| `.specify/templates/plan-template.md` | Source template for technical context, constitution checks, concrete repository structure, and justified complexity. |
| `.specify/templates/tasks-template.md` | Source template for implementation work tied to the feature's user stories. |
| `specs/NNN-feature-name/` | Actual per-feature spec, plan, tasks, and supporting artifacts generated as needed. |

Commands run **inside OpenCode**, one stage at a time: `/speckit.specify` → `/speckit.clarify` when needed → `/speckit.plan` → `/speckit.tasks` → `/speckit.analyze` → `/speckit.implement` → `/speckit.converge`. Constitution review precedes the first feature plan. Review each artifact before proceeding; continue implement/converge only for approved in-scope gaps.

Feature specs must identify affected baseline IDs, scope/exclusions, migration/data-preservation needs, access/time semantics, and open decisions. Include at least a meaningful failure case and preservation case in acceptance criteria. Technical decisions belong in the plan; completion/handoff evidence belongs with the feature artifacts. Template examples are not project requirements or an instruction to create a separate frontend/backend architecture.

Client history is the preferred candidate for the first Spec Kit feature; scope and acceptance criteria still need clarification. No feature artifacts have been generated yet. Git automation and optional extensions were not installed. The owner-approved artifact lifecycle keeps this file as the living baseline, retains completed feature artifacts as delivery history, and uses a new feature for later behavior changes. See `specs/README.md`.

## 8. Known limitations and proposed next work

### Current limitations — not guarantees

- Stylist overlap checks are model-level. Concurrent booking/schedule requests do not have database-enforced interval exclusion or a complete serialization guarantee.
- Normal booking validation prevents **stylist** overlap, not client overlap across different stylists. Demo seeds avoid both, but that is not an application-wide rule.
- No multi-salon tenancy, individual staff permissions, self-booking, or public deployment/backup recovery process is implemented.
- Cancellation deletes data. There is no retained visit-status/audit workflow, although existing appointments remain stored until deleted.
- One shift and one break per date; no cleanup buffers, processing gaps, or split shifts.
- Availability uses separate slot-generation paths in the grid and form. Consolidation should preserve both user flows and get dedicated acceptance tests.
- Contact details and preferences do not establish reminder consent. No outgoing notification or delivery tracking exists.
- No measured production performance target or comprehensive DST-transition test suite has been agreed.

### Discussed roadmap — Proposed, not implementation instructions

| Proposal | Decisions required before building |
| --- | --- |
| Appointment statuses and client history | Allowed states/transitions; cancellation retention; effects on availability; migration of existing bookings. |
| Reminder groundwork | None/Email/SMS preference; consent timestamp semantics; when contact verification is needed; treatment of existing clients. |
| Email reminders | Lead time; time-zone behavior; idempotency; reschedule/cancel handling; retry policy; appointment-linked delivery records and provider. Action Mailer + Solid Queue is the preferred starting direction. |
| Individual staff accounts | Identity-to-stylist relationship, permissions, recovery, and whether client self-booking is in scope. |
| Live collaboration | Which changes broadcast through Turbo Streams and how unsaved form work is protected. |
| Concurrent booking protection | SQLite-compatible serialization/constraints and concurrent-request tests, including schedule changes. |
| Duplicate-client handling | Detection and merge rules, preserving appointments and explicit preferences. |
| Richer service timing | Buffers, stylist-specific duration, or processing gaps—only as needed for real salon workflows. |
| Marketing and public deployment | Marketing content, hosting, domain/TLS setup, persistent storage, and tested backup/restore. |
| Payments/deposits | Later exploration; no payment workflow or provider is selected. |

The previously suggested sequence was statuses/history → reminder groundwork/email → staff accounts → collaboration/concurrency work. The owner has now indicated client history as the likely first feature; its scope remains to be clarified, and status/cancellation changes are not implicitly included. The remaining sequence is a recommendation, not an approved delivery schedule.

## 9. Decision record

| Date | Decision / provenance |
| --- | --- |
| 2026-09-30 | Owner selected Rails as the ongoing SaaS foundation after evaluating a Go calendar prototype, and requested removal of the Go implementation. The isolated experiment and its supporting artifacts were removed; Rails application code and data were unchanged. |
| 2026-09-25 | Consolidate the existing build into a reviewable baseline to guide conversations and future agents. |
| 2026-09-25 | Back up the first draft, then initialize Spec Kit 1.0.11 with the OpenCode integration. Keep the current-state baseline; apply the feature workflow to future bounded changes. Constitution ratification and completed-spec lifecycle are pending owner review. |
| 2026-09-25 | Owner accepted a living baseline plus historical completed feature artifacts and indicated client history as the likely first feature. Keep README focused on development notes and the spec workflow. Explain the constitution as shared development rules; full review remains open. |
| Existing product direction | Rails-first, SQLite, Hotwire, import maps, and Tailwind as the only application asset build. |
| Existing product direction | Chairflow branding; separate planned marketing and app domains. |
| Existing product direction | Shared time-grid calendar with Day/Week views and stable stylist lanes. |
| Existing product direction | Inspect bookings in a details modal before explicitly editing. |
| Existing product direction | Lightweight team coverage and availability planning; payroll/HR functionality excluded. |

Add future decisions with the related change-spec ID and rationale. Update the relevant baseline section when a feature becomes implemented; do not leave contradictory behavior in the roadmap and baseline.
