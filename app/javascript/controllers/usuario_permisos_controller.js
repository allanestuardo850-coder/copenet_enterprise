import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.updateAllControls()
  }

  toggle(event) {
    const checkbox = event.currentTarget
    const row = checkbox.closest("[data-modulo-id]")
    if (!row) return

    this.markPending(row)
    this.updateAllControls()
  }

  toggleAll(event) {
    const control = event.currentTarget
    const panel = control.closest("[data-tabs-target='panel'], .permission-tab-panel")
    if (!panel) return

    const checked = control.checked
    const rows = Array.from(panel.querySelectorAll("[data-modulo-id]"))
    const checkboxes = panel.querySelectorAll("input[type='checkbox'][data-permission-action]")

    checkboxes.forEach((input) => {
      input.checked = checked
    })
    rows.forEach((row) => this.markPending(row))
    this.updateAllControls()
  }

  markPending(row) {
    this.markDirty(row)

    const status = row.querySelector("[data-permission-status]")
    if (!status) return

    status.textContent = "Pendiente"
    status.dataset.state = "saving"
  }

  markDirty(row) {
    const moduloId = row.dataset.moduloId
    if (!moduloId || this.element.querySelector(`input[data-dirty-modulo-id="${moduloId}"]`)) return

    const input = document.createElement("input")
    input.type = "hidden"
    input.name = "usuario_permisos_dirty[]"
    input.value = moduloId
    input.dataset.dirtyModuloId = moduloId
    this.element.appendChild(input)
  }

  updateAllControls() {
    this.element.querySelectorAll(".permission-tab-panel").forEach((panel) => {
      const control = panel.querySelector(".permission-all-toggle input[type='checkbox']")
      if (!control) return

      const checkboxes = Array.from(panel.querySelectorAll("input[type='checkbox'][data-permission-action]"))
      control.checked = checkboxes.length > 0 && checkboxes.every((input) => input.checked)
      control.indeterminate = checkboxes.some((input) => input.checked) && !control.checked
    })
  }
}
