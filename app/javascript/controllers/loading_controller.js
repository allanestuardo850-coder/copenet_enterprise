import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    this.hideOverlay = this.hideOverlay.bind(this)
    this.showOverlay = this.showOverlay.bind(this)
    this.handleSubmitStart = this.handleSubmitStart.bind(this)
    this.handleSubmitEnd = this.handleSubmitEnd.bind(this)
    this.handleClick = this.handleClick.bind(this)

    document.addEventListener("turbo:load", this.hideOverlay)
    document.addEventListener("turbo:render", this.hideOverlay)
    document.addEventListener("turbo:before-visit", this.showOverlay)
    document.addEventListener("turbo:submit-start", this.handleSubmitStart)
    document.addEventListener("turbo:submit-end", this.handleSubmitEnd)
    document.addEventListener("click", this.handleClick)

    requestAnimationFrame(() => this.hideOverlay())
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.hideOverlay)
    document.removeEventListener("turbo:render", this.hideOverlay)
    document.removeEventListener("turbo:before-visit", this.showOverlay)
    document.removeEventListener("turbo:submit-start", this.handleSubmitStart)
    document.removeEventListener("turbo:submit-end", this.handleSubmitEnd)
    document.removeEventListener("click", this.handleClick)
  }

  hideOverlay() {
    if (!this.hasOverlayTarget) return

    this.overlayTarget.classList.add("is-hidden")
    window.setTimeout(() => {
      this.overlayTarget.setAttribute("aria-hidden", "true")
    }, 180)
  }

  showOverlay() {
    if (!this.hasOverlayTarget) return

    this.overlayTarget.classList.remove("is-hidden")
    this.overlayTarget.setAttribute("aria-hidden", "false")
  }

  handleSubmitStart(event) {
    const submitter = event.detail.formSubmission.submitter
    if (submitter) this.activateLoading(submitter)
  }

  handleSubmitEnd(event) {
    const submitter = event.detail.formSubmission?.submitter
    if (submitter) this.deactivateLoading(submitter)

    // Ensure the global overlay never gets stuck after form submissions.
    this.hideOverlay()
  }

  handleClick(event) {
    const trigger = event.target.closest("a.ui-button, button.ui-button, .button-link, .dropdown-button")
    if (!trigger) return
    if (trigger.tagName === "A" && (!trigger.href || trigger.getAttribute("href") === "#")) return
    if (this.isSubmitTrigger(trigger)) return

    this.activateLoading(trigger)
  }

  activateLoading(element) {
    if (!element || element.classList.contains("is-loading")) return

    element.classList.add("is-loading")

    if ("disabled" in element) {
      element.disabled = true
    }
  }

  deactivateLoading(element) {
    if (!element) return

    element.classList.remove("is-loading")

    if ("disabled" in element) {
      element.disabled = false
    }
  }

  isSubmitTrigger(element) {
    if (!element || element.tagName !== "BUTTON") return false

    const type = (element.getAttribute("type") || "submit").toLowerCase()
    return type === "submit"
  }
}
