import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "list",
    "template",
    "priceInput",
    "currencyInput",
    "subtotalField",
    "subtotalDisplay",
    "discountInput",
    "discountDisplay",
    "finalDisplay",
    "currencySummary"
  ]

  static values = { index: Number }

  connect() {
    this.updateTotals()
  }

  add(event) {
    event.preventDefault()

    const content = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", this.indexValue)
    this.listTarget.insertAdjacentHTML("beforeend", content)
    this.indexValue += 1
    this.updateTotals()
  }

  remove(event) {
    event.preventDefault()

    const card = event.currentTarget.closest("[data-cotizacion-detalle-item]")
    if (!card) return

    const destroyField = card.querySelector("input[name*='[_destroy]']")

    if (destroyField) {
      destroyField.value = "1"
      card.hidden = true
    } else {
      card.remove()
    }

    this.updateTotals()
  }

  updateTotals() {
    const totalsByCurrency = new Map()

    const subtotal = this.priceInputTargets.reduce((sum, input, index) => {
      if (input.closest("[data-cotizacion-detalle-item]")?.hidden) return sum

      const value = this.parseNumber(input.value)
      const currencyLabel = this.currencyLabelAt(index)
      totalsByCurrency.set(currencyLabel, (totalsByCurrency.get(currencyLabel) || 0) + value)
      return sum + value
    }, 0)

    const multipleCurrencies = totalsByCurrency.size > 1
    const discountPercent = this.hasDiscountInputTarget && !multipleCurrencies ? this.parseNumber(this.discountInputTarget.value) : 0
    const discountAmount = subtotal * (discountPercent / 100)
    const finalAmount = subtotal - discountAmount

    if (this.hasDiscountInputTarget) {
      this.discountInputTarget.disabled = multipleCurrencies
      if (multipleCurrencies) this.discountInputTarget.value = ""
    }

    if (this.hasSubtotalFieldTarget) this.subtotalFieldTarget.value = subtotal.toFixed(2)
    if (this.hasSubtotalDisplayTarget) this.subtotalDisplayTarget.textContent = this.formatCurrency(subtotal)
    if (this.hasDiscountDisplayTarget) this.discountDisplayTarget.textContent = this.formatCurrency(discountAmount)
    if (this.hasFinalDisplayTarget) this.finalDisplayTarget.textContent = this.formatCurrency(finalAmount)
    if (this.hasCurrencySummaryTarget) this.renderCurrencySummary(totalsByCurrency)
  }

  parseNumber(value) {
    const normalized = String(value || "").replace(/,/g, "")
    const number = Number.parseFloat(normalized)
    return Number.isFinite(number) ? number : 0
  }

  formatCurrency(value) {
    const currency = "Q"
    return `${currency} ${new Intl.NumberFormat("en-US", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(value || 0)}`
  }

  currencyLabelAt(index) {
    const select = this.currencyInputTargets[index]
    if (!select) return "Sin moneda"

    return select.options[select.selectedIndex]?.text || "Sin moneda"
  }

  renderCurrencySummary(totalsByCurrency) {
    const chips = Array.from(totalsByCurrency.entries()).map(([currency, total]) => {
      const amount = new Intl.NumberFormat("en-US", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(total || 0)

      return `<span class="currency-summary-chip">${currency} · ${amount}</span>`
    })

    this.currencySummaryTarget.innerHTML = chips.join("")
  }
}
