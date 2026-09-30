# chairflow

chairflow is a calm, minimal appointment book for a small family-run hair salon. It replaces outdated or bloated salon software with a few welcoming screens. It is deliberately **not** an ERP. Every feature must earn its place, and the voice of the UI ("A moment in the chair", "Make room for someone.") is part of the product. It is a Rails 8 monolith on SQLite with Hotwire (Turbo + Stimulus) and Tailwind, built by one developer in small, frequently committed steps.

> **Status:** `main` is a fresh build; the prior POC and its lode live only on `archive/poc-v1` (tag `poc-v1`) and aren't carried forward. The full scheduling model layer exists (stylists, services, clients, appointments with services, salon hours, availability), structured JSON request logging, Playwright system tests in CI, and Calendar's day view at `/` — stylist columns with appointment cards placed by time, date navigation (← → Today), an appointment count, and a closed-day message. Not yet built: appointment detail, booking, and the Clients/Salon hours pages. See [plans/roadmap.md](plans/roadmap.md) for what's tracked next. Everywhere else in this lode still describes the **planned MVP**; code is the source of truth wherever the two disagree.

## MVP scope
The normal business flows, and nothing more: **see the day, book (one or more services), edit or reschedule, cancel, add or find clients** (with a warning when a new client looks like a duplicate), and **set the salon's opening hours**. Everything else is listed under "After MVP" in [plans/roadmap.md](plans/roadmap.md).

```mermaid
flowchart LR
  FD[Front desk or stylist] --> CAL[Day view]
  CAL --> DET[Appointment detail]
  CAL --> NEW[New appointment]
  NEW --> CL[Find or add client]
  DET --> EDIT[Edit / reschedule / cancel]
  FD --> CLIENTS[Clients]
  FD --> HRS[Salon hours]
```

## Where to look next
[terminology.md](terminology.md) · [practices.md](practices.md) · [scheduling/summary.md](scheduling/summary.md) · [booking/summary.md](booking/summary.md) · [ui/summary.md](ui/summary.md) · [plans/roadmap.md](plans/roadmap.md)
