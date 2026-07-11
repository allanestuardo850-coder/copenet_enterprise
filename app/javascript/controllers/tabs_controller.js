import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { default: String }

  connect() {
    this.boundKeydown = this.keydown.bind(this)
    this.element.addEventListener("keydown", this.boundKeydown)
    this.syncAccessibility()

    const initialTab = this.initialTab()
    if (initialTab) this.show(initialTab)
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.boundKeydown)
  }

  switch(event) {
    event.preventDefault()
    this.show(this.tabIdentifier(event.currentTarget))
  }

  keydown(event) {
    const currentTab = event.target.closest("[data-tabs-target='tab']")
    if (!currentTab || !this.tabTargets.includes(currentTab)) return

    const keys = ["ArrowLeft", "ArrowRight", "Home", "End"]
    if (!keys.includes(event.key)) return

    event.preventDefault()

    const currentIndex = this.tabTargets.indexOf(currentTab)
    const nextIndex = this.nextTabIndex(event.key, currentIndex, this.tabTargets.length)
    const nextTab = this.tabTargets[nextIndex]
    if (!nextTab) return

    nextTab.focus()
    this.show(this.tabIdentifier(nextTab))
  }

  show(tabId) {
    if (!tabId) return

    this.tabTargets.forEach((tab) => {
      const active = this.tabIdentifier(tab) === tabId
      tab.classList.toggle("is-active", active)
      tab.setAttribute("aria-selected", active ? "true" : "false")
      tab.setAttribute("tabindex", active ? "0" : "-1")
    })

    this.panelTargets.forEach((panel) => {
      const active = this.panelIdentifier(panel) === tabId
      panel.hidden = !active
      panel.classList.toggle("is-active", active)
    })
  }

  initialTab() {
    const fromHash = this.identifierFromHash(window.location.hash)
    if (fromHash) return fromHash

    if (this.defaultValue) return this.defaultValue

    return this.tabIdentifier(this.tabTargets[0])
  }

  syncAccessibility() {
    this.tabTargets.forEach((tab, index) => {
      const identifier = this.tabIdentifier(tab) || `tab-${index + 1}`
      tab.dataset.tabId = identifier
      tab.id ||= `tab-${identifier}`
      tab.setAttribute("role", "tab")
      tab.setAttribute("tabindex", "-1")
    })

    this.panelTargets.forEach((panel, index) => {
      const identifier = this.panelIdentifier(panel) || `panel-${index + 1}`
      panel.dataset.tabPanelId = identifier
      panel.id ||= `panel-${identifier}`
      panel.setAttribute("role", "tabpanel")
    })

    this.tabTargets.forEach((tab) => {
      const identifier = this.tabIdentifier(tab)
      const panel = this.panelTargets.find((candidate) => this.panelIdentifier(candidate) === identifier)
      if (!panel) return

      tab.setAttribute("aria-controls", panel.id)
      panel.setAttribute("aria-labelledby", tab.id)
    })
  }

  identifierFromHash(hash) {
    const value = hash.toString().replace(/^#/, "")
    if (!value) return null

    const exactTab = this.tabTargets.find((tab) => [tab.id, this.tabIdentifier(tab)].includes(value))
    if (exactTab) return this.tabIdentifier(exactTab)

    const exactPanel = this.panelTargets.find((panel) => [panel.id, this.panelIdentifier(panel)].includes(value))
    return exactPanel ? this.panelIdentifier(exactPanel) : null
  }

  nextTabIndex(key, currentIndex, total) {
    switch (key) {
      case "ArrowRight":
        return (currentIndex + 1) % total
      case "ArrowLeft":
        return (currentIndex - 1 + total) % total
      case "Home":
        return 0
      case "End":
        return total - 1
      default:
        return currentIndex
    }
  }

  tabIdentifier(tab) {
    return tab?.dataset?.tabId || tab?.dataset?.tabPanelId || null
  }

  panelIdentifier(panel) {
    return panel?.dataset?.tabPanelId || panel?.dataset?.tabId || null
  }
}
