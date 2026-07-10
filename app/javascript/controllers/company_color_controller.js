import { Controller } from "@hotwired/stimulus"

const HEX_PATTERN = /^#?([0-9a-f]{3}|[0-9a-f]{6})$/i

export default class extends Controller {
  static targets = ["input", "picker", "slider", "handle"]
  static values = { fallback: String }

  connect() {
    const initialColor = this.normalize(this.inputTarget.value) || this.normalize(this.fallbackValue) || "#2563eb"
    this.boundDrag = this.drag.bind(this)
    this.boundStopDrag = this.stopDrag.bind(this)
    this.setBaseColor(initialColor, { syncText: !this.inputTarget.value })
  }

  disconnect() {
    this.stopDrag()
  }

  openPicker() {
    this.pickerTarget.click()
  }

  pick() {
    this.setBaseColor(this.pickerTarget.value, { syncText: true })
  }

  type() {
    const color = this.normalize(this.inputTarget.value)
    if (color) this.setBaseColor(color, { syncPicker: true })
  }

  startDrag(event) {
    event.preventDefault()
    this.sliderTarget.setPointerCapture?.(event.pointerId)
    this.drag(event)
    window.addEventListener("pointermove", this.boundDrag)
    window.addEventListener("pointerup", this.boundStopDrag)
  }

  drag(event) {
    const rect = this.sliderTarget.getBoundingClientRect()
    const percent = Math.min(100, Math.max(0, ((event.clientX - rect.left) / rect.width) * 100))
    this.applyShade(percent)
  }

  stopDrag() {
    window.removeEventListener("pointermove", this.boundDrag)
    window.removeEventListener("pointerup", this.boundStopDrag)
  }

  nudge(event) {
    const directions = {
      ArrowLeft: -1,
      ArrowDown: -1,
      ArrowRight: 1,
      ArrowUp: 1
    }
    const direction = directions[event.key]
    if (!direction) return

    event.preventDefault()
    const step = event.shiftKey ? 10 : 2
    this.applyShade(Math.min(100, Math.max(0, this.currentPercent + direction * step)))
  }

  applyColor(color, { syncText = false, syncPicker = false } = {}) {
    this.element.style.setProperty("--company-color", color)
    this.element.classList.toggle("is-invalid", false)

    if (syncText) this.inputTarget.value = color.toUpperCase()
    if (syncPicker || syncText) this.pickerTarget.value = this.toSixDigitHex(color)
  }

  setBaseColor(color, { syncText = false, syncPicker = false } = {}) {
    const normalized = this.toSixDigitHex(this.normalize(color))
    this.baseColor = normalized
    this.element.style.setProperty("--company-color-base", normalized)
    this.applyShade(50, { syncText, syncPicker })
  }

  applyShade(percent, { syncText = true, syncPicker = true } = {}) {
    const color = this.colorAt(percent)
    this.currentPercent = percent
    this.element.style.setProperty("--company-slider-position", `${percent}%`)
    this.handleTarget.setAttribute("aria-valuenow", Math.round(percent))
    this.applyColor(color, { syncText, syncPicker })
  }

  colorAt(percent) {
    if (percent < 50) return this.mixColors("#ffffff", this.baseColor, percent / 50)
    if (percent > 50) return this.mixColors(this.baseColor, "#000000", (percent - 50) / 50)
    return this.baseColor
  }

  normalize(value) {
    const color = (value || "").trim()
    if (!HEX_PATTERN.test(color)) {
      this.element.classList.toggle("is-invalid", color.length > 0)
      return null
    }

    return color.startsWith("#") ? color : `#${color}`
  }

  toSixDigitHex(color) {
    if (!color) return "#2563eb"

    if (color.length === 4) {
      const [, r, g, b] = color
      return `#${r}${r}${g}${g}${b}${b}`.toLowerCase()
    }

    return color.toLowerCase()
  }

  mixColors(from, to, amount) {
    const start = this.hexToRgb(from)
    const end = this.hexToRgb(to)
    const mixed = start.map((channel, index) => Math.round(channel + (end[index] - channel) * amount))

    return this.rgbToHex(mixed)
  }

  hexToRgb(color) {
    const hex = this.toSixDigitHex(color).slice(1)

    return [
      parseInt(hex.slice(0, 2), 16),
      parseInt(hex.slice(2, 4), 16),
      parseInt(hex.slice(4, 6), 16)
    ]
  }

  rgbToHex(channels) {
    return `#${channels.map((channel) => channel.toString(16).padStart(2, "0")).join("")}`
  }
}
