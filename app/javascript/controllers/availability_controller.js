import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["start", "stylist", "duration", "frame"]
  static values = { url: String, appointmentId: String }

  refresh() {
    if (!this.startTarget.value || !this.startTarget.validity.valid) return

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("starts_at", this.startTarget.value)
    url.searchParams.set("stylist_id", this.stylistTarget.value)
    url.searchParams.set("duration_minutes", this.durationTarget.value)
    url.searchParams.set("appointment_id", this.appointmentIdValue)
    this.frameTarget.src = url.toString()
  }

  select(event) {
    this.startTarget.value = event.currentTarget.dataset.time
    this.refresh()
  }

  serviceChanged(event) {
    this.durationTarget.value = event.currentTarget.selectedOptions[0].dataset.duration
    this.refresh()
  }

  shiftDay(event) {
    if (!this.startTarget.value) return
    const [date, time] = this.startTarget.value.split("T")
    const day = new Date(`${date}T12:00:00`)
    day.setDate(day.getDate() + Number(event.currentTarget.dataset.days))
    const month = String(day.getMonth() + 1).padStart(2, "0")
    const dateOfMonth = String(day.getDate()).padStart(2, "0")
    this.startTarget.value = `${day.getFullYear()}-${month}-${dateOfMonth}T${time}`
    this.refresh()
  }

  failed(event) {
    event.preventDefault()
    this.frameTarget.innerHTML = '<p role="alert" class="notice">Availability could not load. Check the date and time, then try again.</p>'
  }
}
