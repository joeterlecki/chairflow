# Chairflow agent entry point

Read [SPEC.md](SPEC.md) before planning or changing behavior. It records the current product contracts, stable requirement IDs, design language, architecture, known limitations, and spec-driven workflow. Use [README.md](README.md) for setup and runtime commands.

Spec Kit is initialized for OpenCode. Also read [.specify/memory/constitution.md](.specify/memory/constitution.md) and [specs/README.md](specs/README.md). The constitution is a review draft; roadmap choices and unanswered adoption decisions are not implementation approval.

## Working on a change

1. Check `git status` and preserve existing work, including uncommitted branding or UI changes.
2. Identify the relevant baseline IDs. For substantive new behavior, use the installed Spec Kit workflow to create a focused `specs/NNN-feature-name/spec.md`, then plan and tasks before implementing. Read the active feature artifacts when resuming work. A clear user request can authorize a scoped change; ask only about unresolved material decisions.
3. Treat the roadmap as proposals, not permission to implement adjacent features.
4. Keep business rules in Ruby, reuse the Rails/Hotwire/Tailwind patterns, and preserve the Chairflow design language.
5. Validate against acceptance criteria using relevant Rails/browser checks. Update the spec and README when behavior or setup changes. Report evidence and any remaining gaps.
6. Commit or push only when requested; use Conventional Commits. Never include real credentials, local databases, or generated artifacts.

Use `/speckit.clarify` for uncertain behavior, `/speckit.analyze` for cross-artifact checks, and `/speckit.converge` to assess delivered criteria. Do not retroactively turn the existing application into a new implementation task or fill generic template examples with invented requirements. Keep package-managed templates/commands intact unless a deliberate customization is requested.

## Important boundaries

- This is a single-salon, staff-managed POC with an admin login. Stylists are not login accounts.
- Calendar booking clicks show read-only details; editing is explicit.
- Resolve coverage through `Stylist#schedule_for(date)`: time off, then dated shift, then recurring hours.
- Preserve bookings and client preferences during changes. Cancellation currently deletes a booking; retained statuses/history need their own spec.
- Reminder preferences, consent, delivery, client self-booking, payroll, and AI-agent features are not implemented. Do not infer them from installed Rails infrastructure or Sentry tooling.
- Use the salon's `Time.zone`, not browser/server-local time, for scheduling.
- See `SPEC.md` for the known overlap/concurrency and availability-abstraction limitations.

## Verification entry points

- Rails: `bin/rails test`
- Ruby style: `bin/rubocop`
- Security-sensitive changes: `bin/brakeman --no-pager`
- CSS: `bin/rails tailwindcss:build`
- Browser flows: `just browser-test` (isolated database/server; install prerequisites with `just browser-install`)
- Local Docker delivery: `just up`, then verify the affected flow

Documentation-only changes need factual/reference/diff checks rather than an app rebuild. For agent handoffs, include the spec ID/status, decisions, affected files, verification performed, and unresolved questions.
