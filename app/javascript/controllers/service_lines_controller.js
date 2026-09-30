import { Controller } from "@hotwired/stimulus"

// Adds/removes appointment_services nested-attribute rows from a <template>,
// and keeps a running total of their durations.
export default class extends Controller {
  static targets = ["rows", "template", "row", "duration", "total"]

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

    event.target.closest("[data-service-lines-target='row']").remove()
    this.updateTotal()
  }

  // Prefills the row's minutes field from the chosen service's default duration
  // (data-duration on the <option>); still editable, e.g. for a longer visit.
  fillDuration(event) {
    const option = event.target.selectedOptions[0]
    const duration = option?.dataset.duration
    if (!duration) return

    const row = event.target.closest("[data-service-lines-target='row']")
    const durationInput = row.querySelector("[data-service-lines-target='duration']")
    durationInput.value = duration
    this.updateTotal()
  }

  updateTotal() {
    const total = this.durationTargets.reduce((sum, input) => sum + (parseInt(input.value, 10) || 0), 0)
    this.totalTarget.textContent = `${total} min`
  }
}
