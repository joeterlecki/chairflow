import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const url = new URL(window.location.href)
    if (!url.searchParams.has("view") && window.matchMedia("(max-width: 767px)").matches) {
      url.searchParams.set("view", "day")
      window.Turbo.visit(url.toString(), { action: "replace" })
    }
  }
}
