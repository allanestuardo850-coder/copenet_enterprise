import { Controller } from "@hotwired/stimulus"

// Igual que tabs_controller pero con identificador propio, para poder anidar
// grupos de pestañas dentro de otra pestaña sin que los targets se mezclen
// (Stimulus propaga los targets a todos los controladores ancestros del mismo
// identificador; usar uno distinto evita el conflicto).
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { default: String }

  connect() {
    const initialTab = this.defaultValue || this.tabTargets[0]?.dataset.tabId
    if (initialTab) this.show(initialTab)
  }

  switch(event) {
    event.preventDefault()
    this.show(event.currentTarget.dataset.tabId)
  }

  show(tabId) {
    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.tabId === tabId
      tab.classList.toggle("is-active", active)
      tab.setAttribute("aria-selected", active ? "true" : "false")
    })

    this.panelTargets.forEach((panel) => {
      const active = panel.dataset.tabId === tabId
      panel.hidden = !active
      panel.classList.toggle("is-active", active)
    })
  }
}
