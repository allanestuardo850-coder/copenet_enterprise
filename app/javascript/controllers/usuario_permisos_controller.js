import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  toggle(event) {
    const checkbox = event.currentTarget
    const row = checkbox.closest("[data-modulo-id]")
    if (!row) return

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

    fetch(`${this.urlValue}?modulo_id=${moduloId}`, {
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
        checkbox.checked = !checkbox.checked
        if (status) {
          status.textContent = "Error al guardar"
          status.dataset.state = "error"
        }
      })
      .finally(() => {
        checkboxes.forEach((input) => {
          input.disabled = false
        })
        row.classList.remove("is-saving")
      })
  }
}
