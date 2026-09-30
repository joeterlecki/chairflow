# Booking flow

> Status: an existing client, one or several services (picked from `Service.active`, see below), and a moment — tap a day planner slot or type the time directly, both write to the same field (`appointments#new`/`#create`/`#day_planner`, `resources :appointments, only: [:show, :new, :create]` plus a `day_planner` collection route) — opening as a modal like appointment detail (see below). Not yet built: client search + inline creation, the duplicate warning, and friendly clash handling (today a clash just re-renders the form with `Appointment`'s existing validation message via `shared/_errors`). The order below is the agreed target shape; what's built so far is a plain form, not this flow.

## Intent
Follow how the conversation at the desk goes: *"She wants a cut and a gloss, ideally with Melissa, sometime Wednesday."* The front desk and stylists both book, so the flow must be quick on a phone between clients too.

1. **Services**: one or more. Each gets a duration from the service default, adjustable for this visit. The total shows as you go ("90 min").
2. **Stylist**: preselected from the client's preferred stylist when the client is already known.
3. **Moment**: tap an open slot in the day planner ("Find the right moment"), or type a time.
4. **Client**: one search box. Matches appear as you type, and the last option is always *"+ Add "Jane Doe" as a new client"*. See [../clients/summary.md](../clients/summary.md) for the duplicate warning.
5. **Notes** (optional), then **Book appointment** / **Never mind**.

```mermaid
flowchart TD
  S[Add services] --> D[Total duration]
  D --> ST[Choose stylist]
  ST --> P[Day planner: open slots]
  P -->|tap slot| T[starts_at set]
  T --> C{Client search}
  C -->|existing| CE[client_id]
  C -->|+ Add new| DUP{Possible duplicate?}
  DUP -->|no| CN[new client]
  DUP -->|yes| W[Warn: use existing, or add anyway]
  W --> CN
  W --> CE
  CE --> B[Book appointment]
  CN --> B
  B -->|valid| OK[Day view, flash, new card highlighted]
  B -->|clash| ERR[Kind error, planner refreshed]
```

## New appointment is a modal, like appointment detail
Consistent with [../ui/calendar-views.md](../ui/calendar-views.md)'s appointment detail dialog — same `modal` Turbo Frame, same `<dialog data-controller="modal">` (`showModal()` on connect), same centering fix (`m-auto`, since Tailwind's preflight strips the browser default). The day view's "+ New appointment" link carries `data: { turbo_frame: "modal" }` to load `appointments/new` into the frame.

The form itself (`app/views/appointments/_form.html.erb`) needs `data: { turbo_frame: "_top" }` on `form_with` — without it, Turbo scopes the submission response to the `modal` frame it's nested in, which is wrong for *both* outcomes: a successful `create` redirects to `root_path` (the whole calendar should update, not just the frame), and a failed one re-renders `:new` with errors (still a full page render with layout, meant to replace the whole document, not be spliced into the existing frame). "Never mind" needs the same `data: { turbo_frame: "_top" }` on its `link_to`, for the same reason — without it, cancelling would fetch `root_path` and splice only its (empty) `modal` frame back in, rather than doing a real navigation back to the calendar.

## One Stimulus controller for the whole form
`app/javascript/controllers/booking_form_controller.js` covers everything interactive in the form: adding/removing service rows, the running total, prefilling a row's duration, and refreshing the day planner. It started out scoped to just the service rows (`service_lines_controller.js`) and was renamed and extended once the day planner needed to react to the *same* stylist/duration changes — one controller wrapping the whole `<form>` made that coordination trivial (shared targets), rather than two controllers passing state between each other.

```erb
<%# app/views/appointments/_form.html.erb (excerpt) %>
<%= form_with model: appointment, data: { turbo_frame: "_top", controller: "booking-form" } do |form| %>
  <%= form.collection_select :stylist_id, Stylist.active, :id, :name, { prompt: true },
        data: { "booking-form-target": "stylist", action: "change->booking-form#refreshPlanner" } %>

  <div data-booking-form-target="rows">
    <%= form.fields_for :appointment_services do |line| %>
      <%= render "service_line", line: line %>
    <% end %>
  </div>
  <template data-booking-form-target="template">
    <%= form.fields_for :appointment_services, AppointmentService.new, child_index: "NEW_RECORD" do |line| %>
      <%= render "service_line", line: line %>
    <% end %>
  </template>
  <button type="button" data-action="booking-form#add">+ Add a service</button>
  <p>Total: <span data-booking-form-target="total">0 min</span></p>

  <%= turbo_frame_tag "day_planner", src: day_planner_appointments_path(date: date), data: { "booking-form-target": "plannerFrame" } %>

  <%= form.datetime_local_field :starts_at, data: { "booking-form-target": "startsAt" } %>
<% end %>
```

## Services: picked from the catalog, with an adjustable duration
Each service row (`app/views/appointments/_service_line.html.erb`) is a `<select>` of `Service.active` (styled, see [../ui/design-tokens.md](../ui/design-tokens.md)'s `select_chevron`) plus a minutes field. Picking a service prefills minutes from its `default_duration_minutes` (each `<option>` carries a `data-duration`; `booking_form_controller.js#fillDuration` copies it into the row's minutes input on `change`) — still editable, for a visit that runs long or short. `AppointmentsController#service_rows` passes `service_id` and (if present) `duration_minutes` straight through to `accepts_nested_attributes_for`; `position` is computed server-side from row order, not a submitted field, so JS never needs to keep a hidden position input in sync across add/remove.

**Booking does not create services.** An earlier version let typing an unrecognized name create a new `Service` on the spot; that was deliberately reverted. Creating services — and, later, setting their prices — is planned as an admin/power-user function (a Services management page, not yet built; see "Later" in [../plans/roadmap.md](../plans/roadmap.md)'s After MVP list), not something the front desk does implicitly while booking a client.

The last remaining service row can't be removed (`Appointment` requires at least one service regardless, but the UI also blocks it so the total never silently goes empty).

## Day planner ("Find the right moment")
`AppointmentsController#day_planner` (`GET /appointments/day_planner`) computes `Availability.new(stylist:, date:, duration:).open_slots` and renders them as buttons inside a `turbo_frame_tag "day_planner"`. It reloads whenever the stylist select or any service row's minutes changes (`booking_form_controller.js#refreshPlanner`, called from `fillDuration`/`updateTotal`/the stylist select's own `change`), by rewriting the frame's own `src` with the current `stylist_id` and total `minutes` as query params.

Before a stylist is chosen, or with zero total minutes, there's nothing to compute — the frame shows "Choose a stylist and a service to see open times." rather than every active stylist's day (that fallback, so the planner is never an empty box even before narrowing to one stylist, is deferred; not needed for the roadmap's done-when).

Tapping a slot button doesn't submit a hidden field — it directly sets the visible `Time` field's value (`data-planner-value="2026-10-01T09:45"`, exactly the `datetime-local` format, via `booking_form_controller.js#choose`). This is why typing a time and tapping a slot are really the same mechanism from the form's point of view: both just write to `startsAt`, so either one is a complete, valid way to set the moment, matching the "tap a slot, or type a time" intent.

The planner's date comes from the day you were viewing when you opened "+ New appointment" (`new_appointment_path(date: ...)`, defaulting to today), not a separate date picker in the form — see [../ui/calendar-views.md](../ui/calendar-views.md) for the day view side of that link.

```ruby
# app/controllers/appointments_controller.rb (excerpt)
def day_planner
  date = parse_date(params[:date]) || Date.current
  stylist = Stylist.active.find_by(id: params[:stylist_id])
  minutes = params[:minutes].to_i

  @slots = stylist && minutes.positive? ? Availability.new(stylist: stylist, date: date, duration: minutes.minutes).open_slots : []
  @stylist = stylist
  @minutes = minutes

  render layout: false
end
```

## Creating a client inline (planned; today the client must already exist)
New clients will be created in the same transaction as the appointment, so a failed booking leaves no orphan client. `AppointmentsController#create` (current code, not pasted here to avoid drifting out of sync — see the file) builds the `Appointment` from the picked `service_id`s directly; it does not create anything besides the appointment itself. Inline client creation (wrapping `create` in `Appointment.transaction`, building `@appointment.client` from typed name/email/phone when no `client_id` is chosen) arrives with the client search box.

## Rules
- `ends_at` is derived from `starts_at` plus the total of the services (see [../scheduling/overlap-prevention.md](../scheduling/overlap-prevention.md)).
- A new client's preferred stylist defaults to the appointment's stylist.
- Editing an existing client's contact details happens in Clients, not here.
- Editing an appointment uses the same form with eyebrow "A change of plans".
