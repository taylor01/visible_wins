import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close dropdown when clicking outside
    this.outsideClick = this.outsideClick.bind(this)
    document.addEventListener("click", this.outsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.outsideClick)
  }

  toggle(event) {
    event.stopPropagation()
    
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.element.querySelector("button").setAttribute("aria-expanded", "true")
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.element.querySelector("button").setAttribute("aria-expanded", "false")
  }

  outsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  // Handle keyboard navigation
  keydown(event) {
    if (event.key === "Escape") {
      this.close()
      this.element.querySelector("button").focus()
    }
  }
}