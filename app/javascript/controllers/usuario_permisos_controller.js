import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.updateAllControls()
  }

  toggle(event) {
    const checkbox = event.currentTarget
    const row = checkbox.closest("[data-modulo-id]")
    if (!row) return

    this.saveRow(row, checkbox).finally(() => this.updateAllControls())
  }

  toggleAll(event) {
    const control = event.currentTarget
    const panel = control.closest("[data-tabs-target='panel'], .permission-tab-panel")
    if (!panel) return

    const checked = control.checked
    const rows = Array.from(panel.querySelectorAll("[data-modulo-id]"))
    const checkboxes = panel.querySelectorAll("input[type='checkbox'][data-permission-action]")

    control.disabled = true
    checkboxes.forEach((input) => {
      input.checked = checked
    })

    Promise.all(rows.map((row) => this.saveRow(row)))
      .catch(() => {
        checkboxes.forEach((input) => {
          input.checked = !checked
        })
      })
      .finally(() => {
        control.disabled = false
        this.updateAllControls()
      })
  }

  saveRow(row, sourceCheckbox = null) {
    const moduloId = row.dataset.moduloId
    const status = row.querySelector("[data-permission-status]")
    const checkboxes = row.querySelectorAll("input[type='checkbox'][data-permission-action]")
    const token = document.querySelector("meta[name='csrf-token']")?.content

    const permisos = {}
    checkboxes.forEach((input) => {
      permisos[input.dataset.permissionAction] = input.checked ? "1" : "0"
      input.disabled = true
    })

    row.classList.add("is-saving")
    if (status) {
      status.textContent = "Guardando..."
      status.dataset.state = "saving"
    }

    return fetch(`${this.urlValue}?modulo_id=${moduloId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": token
      },
      body: JSON.stringify({ usuario_permisos: permisos })
    })
      .then(async (response) => {
        if (!response.ok) throw new Error("No se pudo actualizar")
        return response.json()
      })
      .then(() => {
        if (status) {
          status.textContent = "Actualizado"
          status.dataset.state = "saved"
        }
      })
      .catch(() => {
        if (sourceCheckbox) sourceCheckbox.checked = !sourceCheckbox.checked
        if (status) {
          status.textContent = "Error al guardar"
          status.dataset.state = "error"
        }
        throw new Error("No se pudo actualizar")
      })
      .finally(() => {
        checkboxes.forEach((input) => {
          input.disabled = false
        })
        row.classList.remove("is-saving")
      })
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
