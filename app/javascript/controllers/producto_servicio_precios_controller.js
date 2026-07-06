import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]
  static values = { index: Number }

  add(event) {
    event.preventDefault()

    const content = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", this.indexValue)
    this.listTarget.insertAdjacentHTML("beforeend", content)
    this.indexValue += 1
  }

  remove(event) {
    event.preventDefault()

    const card = event.currentTarget.closest("[data-precio-item]")
    if (!card) return

    const destroyField = card.querySelector("input[name*='[_destroy]']")

    if (destroyField) {
      destroyField.value = "1"
      card.hidden = true
    } else {
      card.remove()
    }
  }
}
