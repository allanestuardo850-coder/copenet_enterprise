import { Controller } from "@hotwired/stimulus"

// Guarda los permisos en tiempo real (sin botón): cada cambio en un checkbox
// envía el formulario por fetch al endpoint de permisos y muestra el estado.
export default class extends Controller {
  static targets = ["status"]

  connect() {
    this.form = this.element.closest("form")
    this.saveTimer = null
    this.updateAllControls()
  }

  toggle(event) {
    const row = event.currentTarget.closest("[data-modulo-id]")
    if (row) this.markDirty(row)
    this.updateAllControls()
    this.scheduleSave()
  }

  toggleAll(event) {
    const control = event.currentTarget
    const panel = control.closest("[data-tabs-target='panel'], .permission-tab-panel")
    if (!panel) return

    const checked = control.checked
    panel.querySelectorAll("input[type='checkbox'][data-permission-action]").forEach((input) => {
      input.checked = checked
    })
    panel.querySelectorAll("[data-modulo-id]").forEach((row) => this.markDirty(row))
    this.updateAllControls()
    this.scheduleSave()
  }

  scheduleSave() {
    if (!this.form) return

    this.setStatus("Guardando…", "saving")
    clearTimeout(this.saveTimer)
    this.saveTimer = setTimeout(() => this.save(), 500)
  }

  async save() {
    if (!this.form) return

    try {
      const response = await fetch(this.form.action, {
        method: "POST",
        body: new FormData(this.form),
        headers: { Accept: "application/json", "X-Requested-With": "XMLHttpRequest" }
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      this.clearDirty()
      this.setStatus("Cambios guardados", "saved")
    } catch (error) {
      this.setStatus("No se pudo guardar. Intenta de nuevo.", "error")
    }
  }

  setStatus(text, state) {
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = text
    this.statusTarget.dataset.state = state
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

  clearDirty() {
    this.element.querySelectorAll("input[data-dirty-modulo-id]").forEach((input) => input.remove())
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
