class CotizacionDetalle < ApplicationRecord
  attr_accessor :current_usuario

  belongs_to :cotizacion, class_name: "Cotizacion", inverse_of: :cotizacion_detalles
  belongs_to :moneda, optional: true
  belongs_to :producto_servicio_precio, optional: true

  SECCIONES_COTIZACION = ProductoServicioPrecio::SECCIONES_COTIZACION

  before_validation :hidratar_valores_base
  before_validation :aplicar_reglas_precio
  after_commit :registrar_auditoria_precio, on: %i[create update]

  validates :descripcion, presence: true, length: { maximum: 300 }
  validates :precio, numericality: { greater_than_or_equal_to: 0 }
  validates :catalog_price, :applied_price, :internal_cost, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :orden, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :recurrencia, inclusion: { in: ProductoServicioPrecio::RECURRENCIAS }, allow_blank: true
  validates :seccion_cotizacion, inclusion: { in: SECCIONES_COTIZACION }, allow_blank: true
  validates :price_override_reason, presence: true, if: :manual_price_override?

  scope :ordenados, -> { order(:orden, :id) }

  def monto_facturable
    return 0.to_d unless facturable?
    return 0.to_d if applied_price.to_d.zero? && !billing_authorized?

    applied_price.to_d
  end

  def valor_no_cobrado
    return 0.to_d unless price_rule_applied == "NO_CHARGE_COPENET"

    catalog_price.to_d - applied_price.to_d
  end

  private

  def hidratar_valores_base
    self.catalog_price = producto_servicio_precio&.precio || catalog_price || precio || applied_price
    self.applied_price = applied_price.presence || precio.presence || catalog_price
    self.internal_cost = cotizacion&.producto_servicio&.costo_base.to_d if internal_cost.blank?
    self.moneda_id ||= producto_servicio_precio&.moneda_id || cotizacion&.producto_servicio&.moneda_id
    self.descripcion = producto_servicio_precio&.nombre if descripcion.blank? && producto_servicio_precio.present?
    self.recurrencia ||= producto_servicio_precio&.recurrencia
    self.seccion_cotizacion ||= producto_servicio_precio&.seccion_cotizacion
    self.facturable = cotizacion&.producto_servicio&.billable? if self[:facturable].nil? && cotizacion&.producto_servicio.present?
  end

  def aplicar_reglas_precio
    precio_sugerido = precio_aplicado_por_regla
    precio_previo = applied_price.to_d

    self.manual_price_override = price_override_reason.present? && applied_price.present? && applied_price.to_d != precio_sugerido.to_d
    self.price_rule_applied = regla_precio_aplicable

    if manual_price_override?
      self.discount_reason = price_override_reason.presence || "Ajuste manual de precio"
    else
      self.applied_price = precio_sugerido
      self.price_override_reason = nil
      self.discount_reason = motivo_regla_precio
    end

    self.applied_price ||= precio_previo
    self.discount_amount = (catalog_price.to_d - applied_price.to_d).round(2)
    self.precio = applied_price.to_d
    self.facturable = false if applied_price.to_d.zero? && !billing_authorized?
  end

  def precio_aplicado_por_regla
    return 0.to_d if regla_precio_aplicable == "NO_CHARGE_COPENET"

    catalog_price.to_d
  end

  def regla_precio_aplicable
    producto = cotizacion&.producto_servicio
    cliente = cotizacion&.cliente_registro
    return "NO_CHARGE_COPENET" if producto&.no_charge_for_copenet? && cliente&.is_copenet_client?

    "CATALOG_PRICE"
  end

  def motivo_regla_precio
    return "Producto sin cobro para cliente CopeNET" if regla_precio_aplicable == "NO_CHARGE_COPENET"

    nil
  end

  def registrar_auditoria_precio
    return unless saved_change_to_applied_price? || (previous_changes.key?("id") && (manual_price_override? || price_rule_applied == "NO_CHARGE_COPENET"))

    AuditoriaPrecioCotizacion.create!(
      cotizacion: cotizacion,
      cotizacion_detalle: self,
      usuario: current_usuario || Current.usuario,
      original_price: catalog_price.to_d,
      previous_applied_price: saved_change_to_applied_price&.first,
      new_applied_price: applied_price.to_d,
      reason: price_override_reason.presence || discount_reason,
      price_rule_applied: price_rule_applied,
      changed_at: Time.current
    )
  end
end
