import { Controller } from "@hotwired/stimulus"

// The whole "New appointment" form: add/remove service rows with a running
// total, prefilling each row's duration from the chosen service, and the day
// planner (reloaded whenever the stylist or total duration changes; tapping a
// slot fills the Time field).
export default class extends Controller {
  static targets = ["rows", "template", "row", "duration", "total", "stylist", "plannerFrame", "startsAt"]

  connect() {
    this.updateTotal()
  }

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, Date.now())
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
    this.updateTotal()
  }

  remove(event) {
    event.preventDefault()
    if (this.rowTargets.length <= 1) return

    event.target.closest("[data-booking-form-target='row']").remove()
    this.updateTotal()
  }

  // Prefills the row's minutes field from the chosen service's default duration
  // (data-duration on the <option>); still editable, e.g. for a longer visit.
  fillDuration(event) {
    const option = event.target.selectedOptions[0]
    const duration = option?.dataset.duration
    if (!duration) return

    const row = event.target.closest("[data-booking-form-target='row']")
    row.querySelector("[data-booking-form-target='duration']").value = duration
    this.updateTotal()
  }

  updateTotal() {
    const total = this.totalMinutes()
    this.totalTarget.textContent = `${total} min`
    this.refreshPlanner()
  }

  refreshPlanner() {
    if (!this.hasPlannerFrameTarget || !this.hasStylistTarget) return

    const url = new URL(this.plannerFrameTarget.src, window.location.origin)
    url.searchParams.set("stylist_id", this.stylistTarget.value)
    url.searchParams.set("minutes", this.totalMinutes())
    this.plannerFrameTarget.src = url.toString()
  }

  choose(event) {
    this.startsAtTarget.value = event.currentTarget.dataset.plannerValue
  }

  totalMinutes() {
    return this.durationTargets.reduce((sum, input) => sum + (parseInt(input.value, 10) || 0), 0)
  }
}
