<!--
Sync Impact Report — adoption follow-up, 2026-09-25
Version: 0.1.0 -> 0.2.0 (minor: owner-approved artifact-lifecycle policy)
Principles: unchanged; added a plain-language explanation of the document.
Added guidance: living baseline with historical completed feature artifacts.
Removed guidance: completed-spec lifecycle is no longer an open question.
Template/command changes: none; installed Spec Kit assets read this file at runtime.
Deferred: TODO(RATIFICATION_DATE) — owner review is pending.
Follow-up decisions are recorded in specs/README.md.
Remove this temporary sync report before committing the reviewed constitution.
-->

# Chairflow Constitution

**Status:** Draft for owner review. This records the development direction already established
for the project; it does not approve roadmap features or invent a new product scope.

“Constitution” is Spec Kit's name for our shared development rules. In plain English: keep the Rails
approach simple, preserve bookings and client choices, keep Chairflow's design consistent, define
behavior before building it, and verify that changes work. It gives future agents the same context
without requiring the owner to repeat those preferences for every feature.

## Core Principles

### I. Bounded, specification-driven changes

Every substantive behavior change MUST begin with a user outcome, explicit scope, acceptance
criteria, and references to affected `CF-*` baseline requirements. Use Spec Kit to describe the
next bounded change, not to rebuild or retroactively reimplement the application.

The current-state reference is [SPEC.md](../../SPEC.md). Discussed roadmap items remain proposals
until selected. A clear user request can authorize a scoped change; unresolved material decisions
MUST be surfaced rather than silently filled in. Keep trivial copy/documentation fixes lightweight.

### II. Rails-first, server-owned business rules

Use the existing Rails, Active Record, SQLite, ERB, Hotwire/Turbo, import-map, and Tailwind
architecture. Keep domain calculations and validation in Ruby; Stimulus handles small interactions.
Tailwind remains the only application asset build, and Node is for browser-test tooling.

Scheduling MUST use the salon's `Time.zone`. Resolve coverage through `Stylist#schedule_for(date)`:
time off, then dated shift, then recurring hours. Reuse shared working-hours rules and validate
booking changes on the server. Do not introduce a second client-side scheduling authority or claim
that the current model-level overlap check provides a concurrency guarantee.

Changes of database, frontend architecture, external infrastructure, or significant dependencies
require a documented need and explicit agreement. Prefer small conventional Rails components over
speculative abstractions.

### III. Preserve operational data and explicit client choices

Migrations and feature changes MUST explain how existing appointments, schedules, clients, and
preferences are preserved. A saved No preference is an intentional null, not missing data to fill
from every subsequent appointment. Seeds and development tooling MUST NOT reset operational data.

Do not silently move/cancel bookings when coverage changes. Keep the current conflict workflow
unless the feature spec explicitly revises it. Cancellation currently deletes appointments;
retained statuses/history need a deliberate data migration and behavior specification.

Credentials, Rails keys, local databases, and generated test/runtime artifacts MUST stay outside
tracked source. Tests use isolated data and test-only credentials.

### IV. Calm, intentional, accessible interactions

Preserve Chairflow's warm neutral palette, muted stylist colors, rounded panels, clear hierarchy,
and concise copy. Reuse existing components/styles before introducing a new visual vocabulary.

Calendar booking clicks inspect read-only details; editing is an explicit action. Maintain the
shared time-grid geometry, stable stylist lanes, and bounded scrolling. Preserve relevant
date/view/filter context. Forms and dialogs MUST support keyboard use and narrow screens, with
visible errors and clear actions; modal dismissal restores focus and calendar position.

### V. Evidence-based delivery, proportionate to the change

Acceptance criteria MUST be specific and observable. Meaningful domain/controller changes need
Rails verification; interactive changes need relevant browser verification. Data migrations need
a preservation/backfill strategy and appropriate checks. Use established RuboCop, Brakeman,
Tailwind, Playwright, and container tooling as appropriate.

Do not add implementation-mirroring tests for trivial edits or require an application rebuild for
documentation-only changes. State what was actually tested, any blocked criteria, and remaining
risks. Sentry configuration, transport acceptance, and confirmed indexed events are different levels
of evidence. Never mark unfinished work complete because code was merely generated.

## Existing-project boundaries

- Chairflow is currently one salon, one salon time zone, and staff-managed scheduling with an
  admin login. Stylists are not login accounts. Individual accounts, permissions, or tenancy need
  their own feature decisions.
- Team scheduling means coverage, breaks, dated shifts, and time off. Payroll, clock-in/out, and HR
  functionality are outside the agreed product direction.
- Contact information exists; reminder preferences, consent, verification, delivery, and delivery
  history do not. Do not infer implemented features from installed Solid Queue/Action Mailer.
- No application AI agent or chat workflow exists. The Sentry/OpenCode integration provides
  development observability tools, not a salon AI feature.
- Marketing and application domains are planned separately. DNS, public deployment, TLS, and
  backup recovery must be explicitly planned before treating this as a hosted production service.
- Keep internal Rails/Compose/volume names unless a deliberate migration covers the change.
  Branding changes must not disconnect existing storage.

## Development workflow and quality gates

Use `AGENTS.md` as the entry point, `SPEC.md` for current behavior, and `README.md` for runtime
instructions. The feature workflow is:

1. `/speckit.specify`: define a bounded user-visible change, compatibility boundaries, and
   independently testable acceptance scenarios. Reference existing `CF-*` baseline IDs.
2. `/speckit.clarify`: resolve material ambiguities before planning. Record assumptions explicitly.
3. `/speckit.plan`: reuse the real Rails structure and document data/access/time implications.
   Check all five principles before and after design; do not adopt generic template architectures.
4. `/speckit.tasks`, then `/speckit.analyze`: create traceable work items and check consistency.
5. `/speckit.implement`: execute approved scope and verify against the scenarios.
6. `/speckit.converge`: report gaps and evidence. Repeat implementation/convergence only for
   in-scope unfinished work; request a scope decision for new features.

Each handoff MUST identify the active feature path, decisions, baseline requirements affected,
files changed, verification results, and remaining questions. Update the current baseline when
behavior is delivered. Use the installed templates without modifying their vendor-owned sources
merely to fill the project constitution.

Git operations and extensions are separate from feature implementation. Commit/push only when
requested, use Conventional Commits, and inspect the working tree before changing it. Preserve
other unfinished work. Do not add git automation, external integrations, or optional Spec Kit
extensions solely because the framework offers them.

## Governance

The owner reviews this initial draft before ratification. Until then, established user decisions
and the recorded baseline remain the operational context; this draft is not permission to expand
the product. When ratified, the constitution governs development principles, while feature specs
define approved changes and `SPEC.md` records the resulting current product contract.

Amendments MUST state the rationale, impacted principles/features, compatibility consequences,
and approval reference. Use MAJOR for incompatible principle changes, MINOR for substantive
additions, and PATCH for non-semantic clarifications. Record ratification/amendment dates in ISO
format. Conflicts between artifacts must be reconciled explicitly, not resolved by whichever file
an agent happened to read last.

The owner approved the artifact lifecycle on 2026-09-25: keep `SPEC.md` as the living product
baseline; evolve a feature's spec/plan/tasks together while building it; retain completed feature
artifacts as delivery history. Later behavior changes get a new feature directory and update the
baseline when delivered. Record factual corrections explicitly instead of silently rewriting old
delivery evidence. This specific approval does not imply ratification of the entire draft.

No numeric performance SLA or scale target is invented by this constitution; feature-specific
claims require an agreed target and evidence.

**Version**: 0.2.0 | **Ratified**: TODO(RATIFICATION_DATE): awaiting owner review | **Last Amended**: 2026-09-25
