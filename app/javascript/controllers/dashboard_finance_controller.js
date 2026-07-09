import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chart", "button"]
  static values = { url: String }
  static classes = ["active"]

  async load(event) {
    event.preventDefault()

    const button = event.currentTarget
    const range = button.dataset.range || "current"
    this.setLoading(true)

    try {
      const response = await fetch(`${this.urlValue}?range=${encodeURIComponent(range)}`, {
        headers: { "Accept": "application/json" }
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const data = await response.json()
      this.chartTarget.innerHTML = this.renderChart(data)
      this.activate(button)
    } catch (error) {
      console.error("No se pudo cargar la gráfica financiera", error)
    } finally {
      this.setLoading(false)
    }
  }

  activate(activeButton) {
    this.buttonTargets.forEach((button) => {
      const active = button === activeButton
      button.classList.toggle(this.activeClass, active)
      button.setAttribute("aria-pressed", active ? "true" : "false")
    })
  }

  setLoading(loading) {
    this.chartTarget.classList.toggle("is-loading", loading)
    this.buttonTargets.forEach((button) => button.disabled = loading)
  }

  renderChart(data) {
    const months = data.months || []
    const ingresos = data.ingresos || []
    const costos = data.costos || []
    const utilidad = data.utilidad || []
    const max = Number(data.max) || 10
    const left = 74
    const right = 1088
    const top = 16
    const bottom = 238
    const plotHeight = bottom - top
    const slot = (right - left) / Math.max(months.length, 1)
    const y = (value) => (bottom - (Number(value || 0) / max) * plotHeight).toFixed(1)
    const steps = [0, 1, 2, 3].map((step) => Math.round(max * step / 3))

    const grid = steps.map((value) => {
      const gy = y(value)
      return `
        <line x1="${left}" y1="${gy}" x2="${right}" y2="${gy}" class="dash-grid"/>
        <text x="${left - 12}" y="${Number(gy) + 4}" class="dash-axis dash-axis-end">Q${value}k</text>
        <text x="${right + 12}" y="${Number(gy) + 4}" class="dash-axis">Q${value}k</text>
      `
    }).join("")

    const bars = months.map((month, index) => {
      const cx = left + slot * (index + 0.5)
      const ingresoY = Number(y(ingresos[index]))
      const costoY = Number(y(costos[index]))
      return `
        <rect x="${(cx - 38).toFixed(1)}" y="${ingresoY}" width="31" height="${(bottom - ingresoY).toFixed(1)}" rx="7" fill="var(--primary)"/>
        <rect x="${(cx + 2).toFixed(1)}" y="${costoY}" width="31" height="${(bottom - costoY).toFixed(1)}" rx="7" fill="var(--primary)" opacity="0.28"/>
        <text x="${cx.toFixed(1)}" y="${bottom + 26}" class="dash-axis dash-axis-mid">${month}</text>
      `
    }).join("")

    const linePoints = months.map((_, index) => {
      const cx = left + slot * (index + 0.5)
      return `${cx.toFixed(1)},${y(utilidad[index])}`
    }).join(" ")

    const points = months.map((_, index) => {
      const cx = left + slot * (index + 0.5)
      return `<circle cx="${cx.toFixed(1)}" cy="${y(utilidad[index])}" r="4" fill="var(--surface-strong)" stroke="var(--success)" stroke-width="2.5"/>`
    }).join("")

    return `
      <svg viewBox="0 0 1160 284" class="dash-chart dash-chart-bars" preserveAspectRatio="xMidYMid meet" role="img" aria-label="Resumen financiero mensual">
        ${grid}
        ${bars}
        <polyline points="${linePoints}" fill="none" stroke="var(--success)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
        ${points}
      </svg>
    `
  }
}
