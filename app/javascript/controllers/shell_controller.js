import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "menu", "themeLabel"]
  static classes = ["sidebarOpen", "menuOpen", "dark", "sidebarCollapsed"]

  connect() {
    this.applyStoredTheme()
    this.applyStoredSidebar()
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    document.addEventListener("click", this.handleDocumentClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentClick)
  }

  toggleSidebar() {
    if (window.innerWidth <= 920) {
      this.sidebarTarget.classList.toggle(this.sidebarOpenClass)
      return
    }

    const isCollapsed = this.element.classList.toggle(this.sidebarCollapsedClass)
    if (isCollapsed) this.closeSidebarSections()
    localStorage.setItem("copenet-sidebar", isCollapsed ? "collapsed" : "expanded")
  }

  closeSidebar() {
    this.sidebarTarget.classList.remove(this.sidebarOpenClass)
    this.closeSidebarSections()
  }

  collapseSidebar() {
    if (window.innerWidth <= 920) {
      this.closeSidebar()
      return
    }

    this.element.classList.add(this.sidebarCollapsedClass)
    this.closeSidebarSections()
    localStorage.setItem("copenet-sidebar", "collapsed")
  }

  closeSidebarSections() {
    if (!this.hasSidebarTarget) return

    this.sidebarTarget.querySelectorAll(".sidebar-section.is-open").forEach((section) => {
      this.setSectionOpen(section, false)
    })
  }

  setSectionOpen(section, open) {
    section.classList.toggle("is-open", open)
    section.querySelector(".sidebar-section-trigger")?.setAttribute("aria-expanded", open ? "true" : "false")
  }

  expandSidebar() {
    if (window.innerWidth <= 920) {
      this.sidebarTarget.classList.add(this.sidebarOpenClass)
      return
    }

    this.element.classList.remove(this.sidebarCollapsedClass)
    localStorage.setItem("copenet-sidebar", "expanded")
  }

  handleDocumentClick(event) {
    if (!this.hasSidebarTarget) return
    if (event.target.closest("[data-action*='shell#toggleSidebar']")) return

    const sidebarIsExpanded = !this.element.classList.contains(this.sidebarCollapsedClass)
    const clickInsideSidebar = this.sidebarTarget.contains(event.target)
    const clickedSidebarLink = event.target.closest(".sidebar-item[href]")
    const clickedLogo = event.target.closest(".sidebar-brand-logo")

    if (window.innerWidth <= 920) {
      if (!clickInsideSidebar || clickedSidebarLink || clickedLogo) this.closeSidebar()
      return
    }

    if (sidebarIsExpanded && (!clickInsideSidebar || clickedSidebarLink || clickedLogo)) {
      this.collapseSidebar()
    }
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

    if (this.element.classList.contains(this.sidebarCollapsedClass)) {
      this.expandSidebar()
      this.closeSidebarSections()
      this.setSectionOpen(section, true)
      return
    }

    const shouldOpen = !section.classList.contains("is-open")
    this.closeSidebarSections()
    this.setSectionOpen(section, shouldOpen)
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
