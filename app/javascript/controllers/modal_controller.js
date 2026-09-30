import { Controller } from "@hotwired/stimulus"

// A <dialog> rendered into the "modal" Turbo Frame needs showModal() to get
// native modal behavior (backdrop, focus trap, Escape to close); the `open`
// attribute alone only renders it inline.
export default class extends Controller {
  connect() {
    this.element.showModal()
  }
}
