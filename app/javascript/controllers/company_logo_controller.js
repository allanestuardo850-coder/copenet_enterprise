import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "empty"]

  preview() {
    const file = this.inputTarget.files?.[0]
    this.renderPreview(file)
  }

  dragOver(event) {
    event.preventDefault()
    this.element.classList.add("is-dragging-logo")
  }

  dragLeave() {
    this.element.classList.remove("is-dragging-logo")
  }

  drop(event) {
    event.preventDefault()
    this.element.classList.remove("is-dragging-logo")

    const files = event.dataTransfer?.files
    if (!files?.length) return

    this.inputTarget.files = files
    this.renderPreview(files[0])
  }

  renderPreview(file) {
    if (!file) return

    if (!file.type.startsWith("image/")) {
      this.inputTarget.value = ""
      return
    }

    const reader = new FileReader()
    reader.onload = (event) => {
      this.previewTarget.innerHTML = `<img class="branding-preview-image" alt="Vista previa del logo corporativo" src="${event.target.result}">`
      this.element.classList.add("has-preview")
    }
    reader.readAsDataURL(file)
  }
}
