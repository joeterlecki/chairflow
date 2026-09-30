import { Controller } from "@hotwired/stimulus"

// The whole "New appointment" form: add/remove service rows with a running
// total, prefilling each row's duration from the chosen service, and the day
// planner (reloaded whenever the stylist or total duration changes; tapping a
// slot fills the Time field).
export default class extends Controller {
  static targets = [
    "rows", "template", "row", "duration", "total", "stylist", "plannerFrame", "startsAt",
    "clientQuery", "clientId", "newClientName", "clientResults", "confirmNewClient"
  ]

  connect() {
    this.totalTarget.textContent = `${this.totalMinutes()} min`
    this.plannerInitialized = false

    if (this.hasPlannerFrameTarget) {
      this.plannerFrameTarget.addEventListener("turbo:before-frame-render", this.capturePlannerHeight)
      this.plannerFrameTarget.addEventListener("turbo:frame-render", this.animatePlannerHeight)

      // A redisplay after a validation error or the duplicate warning can
      // already have a stylist/services chosen -- without this, the planner
      // would show its "choose a stylist" placeholder despite both already
      // being set, until the next change event. plannerInitialized is still
      // false at this point, so this doesn't trigger the height animation.
      if (this.hasStylistTarget && this.stylistTarget.value && this.totalMinutes() > 0) {
        this.refreshPlanner()
      }
    }
  }

  disconnect() {
    if (this.hasPlannerFrameTarget) {
      this.plannerFrameTarget.removeEventListener("turbo:before-frame-render", this.capturePlannerHeight)
      this.plannerFrameTarget.removeEventListener("turbo:frame-render", this.animatePlannerHeight)
    }
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

  // Typing resets any prior choice -- the front desk has to re-pick (or add
  // new) rather than silently keep a stale client_id/new_client_name around.
  searchClients(event) {
    clearTimeout(this.searchTimer)
    this.clientIdTarget.value = ""
    this.newClientNameTarget.value = ""

    const query = event.target.value.trim()
    this.searchTimer = setTimeout(() => {
      const url = new URL(this.clientResultsTarget.dataset.baseUrl, window.location.origin)
      if (query) url.searchParams.set("q", query)
      this.clientResultsTarget.src = url.toString()
    }, 200)
  }

  chooseClient(event) {
    this.clientIdTarget.value = event.currentTarget.dataset.clientId
    this.newClientNameTarget.value = ""
    this.clientQueryTarget.value = event.currentTarget.dataset.clientName
    this.clientResultsTarget.innerHTML = ""
  }

  addNewClient(event) {
    this.clientIdTarget.value = ""
    this.newClientNameTarget.value = event.currentTarget.dataset.clientName
    this.clientQueryTarget.value = event.currentTarget.dataset.clientName
    this.clientResultsTarget.innerHTML = ""
  }

  // The duplicate-warning panel's two resolutions: pick one of the matches
  // (same as a normal search choice), or confirm adding the typed name
  // anyway. Both buttons are type="submit", so setting the field then
  // returning lets the form submit immediately -- one click each.
  useDuplicate(event) {
    this.clientIdTarget.value = event.currentTarget.dataset.clientId
    this.newClientNameTarget.value = ""
    this.clientQueryTarget.value = event.currentTarget.dataset.clientName
  }

  confirmNewClient(event) {
    this.confirmNewClientTarget.value = "1"
  }

  totalMinutes() {
    return this.durationTargets.reduce((sum, input) => sum + (parseInt(input.value, 10) || 0), 0)
  }

  // The <turbo-frame> element itself persists across a frame navigation -- only
  // its content is swapped -- so its height can be animated (a FLIP) even
  // though a plain CSS transition can't apply to content that's replaced
  // wholesale rather than mutated in place.
  //
  // The lock has to happen here, in the *before* handler -- not in the *after*
  // handler once the new content already exists. Locking after the swap means
  // the browser has already painted the new (differently-sized) content for a
  // moment before JS clips it back down, which is the shrink-then-expand jerk.
  // Skipped entirely on the very first load: there's no prior state to
  // transition from, so animating it just produces an unwanted pop.
  capturePlannerHeight = () => {
    if (!this.plannerInitialized) return

    const frame = this.plannerFrameTarget
    this.plannerPreviousHeight = frame.offsetHeight
    frame.style.transition = "none"
    frame.style.overflow = "hidden"
    frame.style.height = `${this.plannerPreviousHeight}px`
  }

  animatePlannerHeight = () => {
    const frame = this.plannerFrameTarget

    if (!this.plannerInitialized) {
      this.plannerInitialized = true
      return
    }

    frame.style.transition = "none"
    frame.style.height = "auto"
    const newHeight = frame.scrollHeight
    frame.style.height = `${this.plannerPreviousHeight}px`
    frame.offsetHeight // force layout, so the browser registers the locked height before animating
    frame.style.transition = "height 200ms ease"
    requestAnimationFrame(() => {
      frame.style.height = `${newHeight}px`
    })
    frame.addEventListener("transitionend", () => {
      frame.style.height = ""
      frame.style.overflow = ""
      frame.style.transition = ""
    }, { once: true })
  }
}
