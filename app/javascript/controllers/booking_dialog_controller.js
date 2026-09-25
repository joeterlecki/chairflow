import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.returnFocus = document.activeElement
    this.previousOverflow = document.documentElement.style.overflow
    document.documentElement.style.overflow = "hidden"
    this.element.showModal()
  }

  disconnect() {
    document.documentElement.style.overflow = this.previousOverflow
    if (this.element.open) this.element.close()
  }

  close(event) {
    event?.preventDefault()
    if (this.element.open) this.element.close()
  }

  backdrop(event) {
    if (event.target !== this.element) return
    const rect = this.element.getBoundingClientRect()
    if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) {
      this.close()
    }
  }

  trapFocus(event) {
    if (event.key !== "Tab") return
    const controls = [...this.element.querySelectorAll('a[href], button:not([disabled]), [tabindex="0"]')]
      .filter(element => element.getClientRects().length > 0)
    const first = controls[0]
    const last = controls[controls.length - 1]
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }

  closed() {
    document.documentElement.style.overflow = this.previousOverflow
    if (this.returnFocus?.isConnected) this.returnFocus.focus({ preventScroll: true })
    const frame = this.element.closest("turbo-frame")
    frame.removeAttribute("src")
    frame.replaceChildren()
  }
}
