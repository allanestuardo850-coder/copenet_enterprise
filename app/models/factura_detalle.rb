class FacturaDetalle < ApplicationRecord
  belongs_to :factura, inverse_of: :factura_detalles
  belongs_to :producto_servicio, optional: true
  belongs_to :producto_servicio_precio, optional: true

  validates :descripcion, presence: true
  validates :cantidad, numericality: { greater_than: 0 }
  validates :precio_unitario, :subtotal, :total, numericality: { greater_than_or_equal_to: 0 }

  before_validation :sincronizar_desde_catalogo
  before_validation :calcular_totales

  def total_formateado
    "#{factura.moneda&.simbolo || 'Q'} #{format('%.2f', total.to_d)}"
  end

  private

  def sincronizar_desde_catalogo
    self.producto_servicio ||= producto_servicio_precio&.producto_servicio
    self.descripcion = descripcion.presence || producto_servicio_precio&.descripcion.presence ||
      producto_servicio_precio&.nombre.presence || producto_servicio&.descripcion.presence ||
      producto_servicio&.nombre
    self.precio_unitario = precio_unitario.presence || producto_servicio_precio&.precio || producto_servicio&.precio_base || 0
    self.afecto_iva = producto_servicio.afecto_iva? if producto_servicio.present? && self[:afecto_iva].nil?
  end

  def calcular_totales
    self.cantidad = 1 if cantidad.blank? || cantidad.to_d <= 0
    self.precio_unitario = 0 if precio_unitario.blank?
    self.subtotal = cantidad.to_d * precio_unitario.to_d
    self.total = subtotal
  end
end
