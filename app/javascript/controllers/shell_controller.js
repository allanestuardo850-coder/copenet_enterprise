import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "menu", "themeLabel"]
  static classes = ["sidebarOpen", "menuOpen", "dark", "sidebarCollapsed"]

  connect() {
    this.applyStoredTheme()
    this.applyStoredSidebar()
  }

  toggleSidebar() {
    if (window.innerWidth <= 920) {
      this.sidebarTarget.classList.toggle(this.sidebarOpenClass)
      return
    }

    const isCollapsed = this.element.classList.toggle(this.sidebarCollapsedClass)
    localStorage.setItem("copenet-sidebar", isCollapsed ? "collapsed" : "expanded")
  }

  closeSidebar() {
    this.sidebarTarget.classList.remove(this.sidebarOpenClass)
  }

  toggleMenu() {
    this.menuTarget.classList.toggle(this.menuOpenClass)
  }

  closeMenu(event) {
    if (this.menuTarget.contains(event.target)) return
    this.menuTarget.classList.remove(this.menuOpenClass)
  }

  toggleSection(event) {
    const section = event.currentTarget.closest(".sidebar-section")
    if (!section) return

    const isOpen = section.classList.toggle("is-open")
    event.currentTarget.setAttribute("aria-expanded", isOpen ? "true" : "false")
  }

  toggleTheme() {
    const isDark = document.documentElement.classList.toggle(this.darkClass)
    localStorage.setItem("copenet-theme", isDark ? "dark" : "light")
    this.updateThemeLabel(isDark)
  }

  applyStoredTheme() {
    const stored = localStorage.getItem("copenet-theme")
    const isDark = stored == "dark"
    document.documentElement.classList.toggle(this.darkClass, isDark)
    this.updateThemeLabel(isDark)
  }

  applyStoredSidebar() {
    if (window.innerWidth <= 920) return

    const stored = localStorage.getItem("copenet-sidebar")
    this.element.classList.toggle(this.sidebarCollapsedClass, stored == "collapsed")
  }

  updateThemeLabel(isDark) {
    if (this.hasThemeLabelTarget) {
      this.themeLabelTarget.textContent = isDark ? "Dark" : "Light"
    }
  }
}
