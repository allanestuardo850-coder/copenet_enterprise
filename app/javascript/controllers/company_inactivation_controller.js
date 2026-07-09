import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["inactiveInput", "modal"]
  static values = { originalInactive: Boolean }

  connect() {
    this.confirmed = false
    this.boundSubmit = this.handleSubmit.bind(this)
    this.element.addEventListener("submit", this.boundSubmit)
  }

  disconnect() {
    this.element.removeEventListener("submit", this.boundSubmit)
  }

  handleSubmit(event) {
    if (this.confirmed || !this.shouldConfirmInactivation()) return

    event.preventDefault()
    this.openModal()
  }

  cancel() {
    this.closeModal()
  }

  confirm() {
    this.confirmed = true
    this.closeModal()
    this.element.requestSubmit()
  }

  shouldConfirmInactivation() {
    return this.hasInactiveInputTarget &&
      this.inactiveInputTarget.checked &&
      !this.originalInactiveValue
  }

  openModal() {
    if (!this.hasModalTarget) return

    this.modalTarget.hidden = false
    document.body.classList.add("modal-open")
  }

  closeModal() {
    if (!this.hasModalTarget) return

    this.modalTarget.hidden = true
    document.body.classList.remove("modal-open")
  }
}
