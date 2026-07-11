import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "tab",
    "panel",
    "clientSelect",
    "clientNameField",
    "clientNamePreview",
    "clientNitPreview",
    "clientEmailPreview",
    "totalField",
    "itemsList",
    "template",
    "itemRow",
    "subtotalDisplay",
    "totalDisplay",
    "summaryClient",
    "summaryTotal"
  ]
  static values = { index: Number }

  connect() {
    this.currentStep = 0
    this.maxUnlockedStep = 0
    this.syncClient()
    this.updateTotals()
    this.showStep(0)
  }

  goToStep(event) {
    const step = Number(event.currentTarget.dataset.step || 0)
    if (step > this.maxUnlockedStep && !this.validateStep(this.currentStep)) return
    if (step > this.maxUnlockedStep) this.maxUnlockedStep = step
    this.showStep(step)
  }

  next(event) {
    event.preventDefault()
    if (!this.validateStep(this.currentStep)) return

    const nextStep = Math.min(this.currentStep + 1, this.panelTargets.length - 1)
    this.maxUnlockedStep = Math.max(this.maxUnlockedStep, nextStep)
    this.showStep(nextStep)
  }

  previous(event) {
    event.preventDefault()
    this.showStep(Math.max(this.currentStep - 1, 0))
  }

  syncClient() {
    if (!this.hasClientSelectTarget) return

    const option = this.clientSelectTarget.selectedOptions[0]
    const name = option?.dataset.name || ""
    const nit = option?.dataset.nit || "CF"
    const email = option?.dataset.email || "Pendiente"

    if (this.hasClientNameFieldTarget) this.clientNameFieldTarget.value = name
    if (this.hasClientNamePreviewTarget) this.clientNamePreviewTarget.textContent = name || "Pendiente"
    if (this.hasClientNitPreviewTarget) this.clientNitPreviewTarget.textContent = nit || "CF"
    if (this.hasClientEmailPreviewTarget) this.clientEmailPreviewTarget.textContent = email || "Pendiente"
    if (this.hasSummaryClientTarget) this.summaryClientTarget.textContent = name || "Pendiente"
  }

  addItem(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", this.indexValue)
    this.itemsListTarget.insertAdjacentHTML("beforeend", content)
    this.indexValue += 1
    this.updateTotals()
  }

  removeItem(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("[data-factura-wizard-target='itemRow']")
    const destroyField = row?.querySelector("[data-factura-wizard-target='itemDestroy']")
    if (!row) return

    if (destroyField) {
      destroyField.value = "1"
      row.hidden = true
    } else {
      row.remove()
    }
    this.updateTotals()
  }

  syncItem(event) {
    const row = event.currentTarget.closest("[data-factura-wizard-target='itemRow']")
    const option = event.currentTarget.selectedOptions[0]
    if (!row || !option) return

    const descriptionField = row.querySelector("[data-factura-wizard-target='itemDescription']")
    const priceField = row.querySelector("[data-factura-wizard-target='itemPrice']")
    const priceIdField = row.querySelector("[data-factura-wizard-target='itemPriceId']")
    const quantityField = row.querySelector("[data-factura-wizard-target='itemQuantity']")

    if (descriptionField) descriptionField.value = option.dataset.description || ""
    if (priceField) priceField.value = this.decimal(option.dataset.price || 0)
    if (priceIdField) priceIdField.value = option.dataset.priceId || ""
    if (quantityField && Number(quantityField.value || 0) <= 0) quantityField.value = 1
    this.updateTotals()
  }

  updateTotals() {
    let total = 0
    this.itemRowTargets.forEach((row) => {
      if (row.hidden) return

      const destroyField = row.querySelector("[data-factura-wizard-target='itemDestroy']")
      if (destroyField?.value === "1") return

      const quantityField = row.querySelector("[data-factura-wizard-target='itemQuantity']")
      const priceField = row.querySelector("[data-factura-wizard-target='itemPrice']")
      const lineTotalField = row.querySelector("[data-factura-wizard-target='itemTotal']")
      const subtotalField = row.querySelector("[data-factura-wizard-target='itemSubtotal']")
      const quantity = Number(quantityField?.value || 0)
      const price = Number(priceField?.value || 0)
      const rowTotal = Math.max(quantity, 0) * Math.max(price, 0)

      if (lineTotalField) lineTotalField.value = this.decimal(rowTotal)
      if (subtotalField) subtotalField.value = this.decimal(rowTotal)
      total += rowTotal
    })

    const formatted = this.currency(total)
    if (this.hasTotalFieldTarget) this.totalFieldTarget.value = this.decimal(total)
    if (this.hasSubtotalDisplayTarget) this.subtotalDisplayTarget.textContent = formatted
    if (this.hasTotalDisplayTarget) this.totalDisplayTarget.textContent = formatted
    if (this.hasSummaryTotalTarget) this.summaryTotalTarget.textContent = formatted
  }

  showStep(step) {
    this.currentStep = step
    this.panelTargets.forEach((panel) => {
      const active = Number(panel.dataset.step) === step
      panel.hidden = !active
      panel.classList.toggle("is-active", active)
    })
    this.tabTargets.forEach((tab) => {
      const tabStep = Number(tab.dataset.step)
      const active = tabStep === step
      tab.classList.toggle("is-active", active)
      tab.classList.toggle("is-disabled", tabStep > this.maxUnlockedStep)
      tab.setAttribute("aria-selected", active ? "true" : "false")
    })
  }

  validateStep(step) {
    this.clearInvalid()
    if (step === 0) return this.validateHeader()
    if (step === 1) return this.validateItems()
    return true
  }

  validateHeader() {
    const invalid = [
      this.clientSelectTarget,
      ...this.element.querySelectorAll("[data-factura-wizard-target='requiredField']")
    ].filter((field) => !field.value)

    invalid.forEach((field) => field.classList.add("is-invalid"))
    return invalid.length === 0
  }

  validateItems() {
    const rows = this.itemRowTargets.filter((row) => {
      const destroyField = row.querySelector("[data-factura-wizard-target='itemDestroy']")
      return !row.hidden && destroyField?.value !== "1"
    })

    const invalid = rows.filter((row) => {
      const product = row.querySelector("select")
      const quantity = row.querySelector("[data-factura-wizard-target='itemQuantity']")
      return !product?.value || Number(quantity?.value || 0) <= 0
    })

    invalid.forEach((row) => row.classList.add("is-invalid"))
    return rows.length > 0 && invalid.length === 0 && Number(this.totalFieldTarget.value || 0) > 0
  }

  clearInvalid() {
    this.element.querySelectorAll(".is-invalid").forEach((node) => node.classList.remove("is-invalid"))
  }

  decimal(value) {
    return Number(value || 0).toFixed(2)
  }

  currency(value) {
    return `Q${this.decimal(value)}`
  }
}
