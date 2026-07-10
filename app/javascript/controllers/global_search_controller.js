import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { items: Array }

  connect() {
    this.matches = []
    this.selectedIndex = 0
    this.closeOnDocumentClick = this.closeOnDocumentClick.bind(this)
    this.focusShortcut = this.focusShortcut.bind(this)
    document.addEventListener("click", this.closeOnDocumentClick)
    document.addEventListener("keydown", this.focusShortcut)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnDocumentClick)
    document.removeEventListener("keydown", this.focusShortcut)
  }

  search() {
    const query = this.inputTarget.value.trim()
    if (!query) {
      this.close()
      return
    }

    this.matches = this.findMatches(query).slice(0, 8)
    this.selectedIndex = 0
    this.render(query)
  }

  keydown(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.submit()
      return
    }

    if (event.key === "Escape") {
      this.close()
      return
    }

    if (!["ArrowDown", "ArrowUp"].includes(event.key)) return
    if (!this.matches.length) return

    event.preventDefault()
    const direction = event.key === "ArrowDown" ? 1 : -1
    this.selectedIndex = (this.selectedIndex + direction + this.matches.length) % this.matches.length
    this.render(this.inputTarget.value.trim())
  }

  submit() {
    const query = this.inputTarget.value.trim()
    if (!query) return

    if (!this.matches.length) {
      this.matches = this.findMatches(query).slice(0, 8)
    }

    const selected = this.matches[this.selectedIndex] || this.matches[0]
    if (!selected) {
      this.render(query)
      return
    }

    window.location.href = selected.path
  }

  choose(event) {
    const index = Number(event.currentTarget.dataset.index)
    const selected = this.matches[index]
    if (!selected) return

    window.location.href = selected.path
  }

  render(query) {
    this.resultsTarget.hidden = false

    if (!this.matches.length) {
      this.resultsTarget.innerHTML = `
        <div class="global-search-empty">
          <strong>Sin resultados</strong>
          <span>No encontramos módulos para "${this.escape(query)}".</span>
        </div>
      `
      return
    }

    this.resultsTarget.innerHTML = this.matches.map((item, index) => `
      <button class="global-search-item ${index === this.selectedIndex ? "is-selected" : ""}"
              type="button"
              data-index="${index}"
              data-action="global-search#choose">
        <span class="global-search-item-icon">${this.iconMarkup(item.icon)}</span>
        <span class="global-search-item-copy">
          <strong>${this.escape(item.label)}</strong>
          ${item.group ? `<small>${this.escape(item.group)}</small>` : ""}
        </span>
        <span class="global-search-enter">Enter</span>
      </button>
    `).join("")
  }

  findMatches(query) {
    const normalizedQuery = this.normalize(query)

    return this.itemsValue
      .map((item) => ({ item, score: this.score(item, normalizedQuery) }))
      .filter(({ score }) => score > 0)
      .sort((a, b) => b.score - a.score || a.item.label.localeCompare(b.item.label))
      .map(({ item }) => item)
  }

  score(item, query) {
    const label = this.normalize(item.label)
    const keywords = (item.keywords || []).map((keyword) => this.normalize(keyword))

    if (label === query) return 100
    if (keywords.includes(query)) return 90
    if (label.startsWith(query)) return 80
    if (keywords.some((keyword) => keyword.startsWith(query))) return 70
    if (label.includes(query)) return 60
    if (keywords.some((keyword) => keyword.includes(query))) return 50
    return 0
  }

  closeOnDocumentClick(event) {
    if (this.element.contains(event.target)) return
    this.close()
  }

  focusShortcut(event) {
    if (!(event.metaKey || event.ctrlKey) || event.key.toLowerCase() !== "k") return
    event.preventDefault()
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  close() {
    this.resultsTarget.hidden = true
    this.resultsTarget.innerHTML = ""
    this.matches = []
    this.selectedIndex = 0
  }

  normalize(value) {
    return String(value || "")
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/ñ/g, "n")
      .trim()
  }

  escape(value) {
    return String(value || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
  }

  iconMarkup() {
    return `<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 4h6v6H4zm10 0h6v6h-6zM4 14h6v6H4zm10 0h6v6h-6z"/></svg>`
  }
}
