import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "menu", "themeLabel"]
  static classes = ["sidebarOpen", "menuOpen", "dark"]

  connect() {
    this.applyStoredTheme()
  }

  toggleSidebar() {
    this.sidebarTarget.classList.toggle(this.sidebarOpenClass)
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

  updateThemeLabel(isDark) {
    if (this.hasThemeLabelTarget) {
      this.themeLabelTarget.textContent = isDark ? "Dark" : "Light"
    }
  }
}
