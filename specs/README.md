# Chairflow — using Spec Kit in an existing project

## Adoption status

- Specify CLI **1.0.11**, initialized with the **OpenCode** integration and Bash scripts.
- Core SDD commands and the bundled `speckit` workflow are installed.
- Current behavior is recorded in the root [SPEC.md](../SPEC.md).
- [Development rules / constitution v0.2.0](../.specify/memory/constitution.md) are drafted from existing decisions and
  **awaiting owner review/ratification**.
- No feature directory, implementation plan, task list, git extension, or optional extension has
  been generated/installed for a new application feature.
- Existing application changes remain in the working tree. Setup did not commit, stash, switch
  branches, or rewrite app code.

The first baseline draft is backed up locally at
`backups/chairflow-baseline-before-spec-kit-2026-09-25.tar.gz` (ignored by Git).
See [backup notes](../backups/README.md) for its contents and checksum.

## Document responsibilities

| Document | Answers |
| --- | --- |
| Root `SPEC.md` | What exists today, what must be preserved, and which gaps remain? |
| `.specify/memory/constitution.md` | Which cross-feature development principles govern planning? |
| `specs/NNN-feature-name/spec.md` | What bounded change does the owner want, and why? |
| `specs/NNN-feature-name/plan.md` | How will we implement it within the existing architecture? |
| `specs/NNN-feature-name/tasks.md` | What concrete work and verification satisfy the feature? |
| Feature supporting artifacts | Research, data model, contracts, quickstart, checklists, and convergence evidence as needed. |
| `AGENTS.md` | What should an agent read and preserve before working? |
| `README.md` | How do we run, test, and operate the application? |

Baseline `CF-*` IDs remain stable. Feature-local `FR-*`, user-story, and task IDs belong to their
feature directory; cite its path when referring to them. Reference the relevant baseline IDs in
feature specs so agents can distinguish an intentional behavior change from an accidental regression.

### Approved artifact lifecycle

Keep root `SPEC.md` as the living description of the current product. While a feature is in progress,
update its spec, plan, and tasks together as decisions change. Once delivered, retain that feature's
artifacts as the historical record of what was requested, built, and verified. Later behavior changes
get a new feature directory and update the baseline when delivered. Record factual corrections
explicitly rather than silently rewriting old delivery evidence. The owner accepted this policy on
2026-09-25.

## Start the next feature

**Restart OpenCode** to load the new `.opencode/commands/speckit.*.md` commands. These are commands
for the agent chat, not commands to paste into a terminal.

1. Review the constitution with `/speckit.constitution`, using the baseline as context. Resolve the
   adoption questions below; do not add invented standards to fill a template.
2. Choose one bounded outcome and use `/speckit.specify`. Include what is changing and the existing
   behavior that must remain compatible. Do not request a rewrite of the existing app.
3. Use `/speckit.clarify` before planning when behavior or data decisions are ambiguous.
4. Run `/speckit.plan`, checking the proposed design against our Rails structure, data model,
   existing tests, and constitution.
5. Run `/speckit.tasks`, then `/speckit.analyze`; review scope and gaps before implementation.
6. Run `/speckit.implement`, then `/speckit.converge`. Close in-scope gaps with evidence; get a
   decision before adding scope. Update the root baseline when behavior is delivered.

Example prompt shape, after choosing the feature:

> Use SPEC.md as the existing-system baseline. Specify [one user-visible outcome]. Identify
> affected CF-* requirements. Preserve existing bookings, explicit client preferences, the
> admin access model, salon time-zone semantics, and the Chairflow design language. List
> unresolved product decisions before planning; do not implement the feature yet.

The CLI already knows the integration and templates. Do not rerun initialization for each feature.
Leave the installed template/command sources unchanged; use supported overrides if a real need for
customization emerges. Git automation is optional; ordinary git work remains explicitly requested.

## Adoption decisions

| ID | Question | Suggested starting point | Status |
| --- | --- | --- | --- |
| ADOPT-001 | Do the shared development rules match how you want contributors and agents to work? | “Constitution” is Spec Kit's name for those rules: use Rails, preserve data, keep the design consistent, and verify changes. Review is still open; uncertainty was not treated as approval. | Awaiting review |
| ADOPT-002 | How should completed feature specs age? | Living root baseline plus historical completed feature artifacts, as described above. | Approved 2026-09-25 |
| ADOPT-003 | What is the first bounded feature to take through Spec Kit? | Owner indicated **client history** as the likely first feature. Clarify its scope before planning; appointment statuses and retention are not automatically included. | Preferred direction; scope pending |

We already know the stack, branding, domain split, current access model, and excluded payroll/HR
scope. Those do not need to be re-decided during adoption.

### Client-history questions for the first spec

- Is the first version a client detail page listing past and upcoming appointments, including
  service, stylist, date/time, and visit notes?
- Should it also retain cancelled/no-show appointments? Cancellation currently deletes the record;
  changing that requires explicit status/retention decisions and a migration. Previously deleted
  bookings cannot be reconstructed from the current database.
- Are existing visit notes sufficient, or are separate long-lived client notes needed?

These are clarification prompts, not decided requirements. Audience/scale targets, notification
providers, and hosting decisions should be requested only when the selected feature depends on them.

## Useful terminal checks

```sh
specify version
specify integration status --json
specify artifact list --json
```

`specify integration status` validates the installed scaffolding; it does not validate application
behavior or approve a feature. Follow the Rails/browser checks in the baseline for implementation.

## References

- [Spec Kit existing-project guide](https://github.github.io/spec-kit/guides/existing-projects.html)
- [Spec Kit SDD commands](https://github.github.io/spec-kit/reference/agentic-sdd.html)
- [Spec persistence choices](https://github.github.io/spec-kit/concepts/spec-persistence.html)
