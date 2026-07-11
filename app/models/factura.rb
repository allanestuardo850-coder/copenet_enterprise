class Factura < ApplicationRecord
  ESTADOS = %w[borrador emitida enviada pagada anulada inactiva].freeze

  belongs_to :cliente, optional: true
  belongs_to :moneda, optional: true
  belongs_to :company, optional: true
  has_one :dte, dependent: :destroy
  has_many :factura_detalles, dependent: :destroy, inverse_of: :factura
  accepts_nested_attributes_for :factura_detalles,
                                allow_destroy: true,
                                reject_if: ->(attributes) do
                                  attributes["producto_servicio_id"].blank? &&
                                    attributes["producto_servicio_precio_id"].blank? &&
                                    attributes["descripcion"].blank?
                                end

  validates :cliente_nombre, :estado, presence: true
  validates :numero, uniqueness: true, allow_blank: true
  validates :estado, inclusion: { in: ESTADOS }
  validates :total, numericality: { greater_than_or_equal_to: 0 }

  before_validation :sincronizar_cliente_nombre
  before_validation :calcular_total_desde_detalles

  scope :ordenadas, -> { order(fecha_emision: :desc, created_at: :desc) }
  scope :activas, -> { where(activo: true) }

  def total_formateado
    "#{moneda&.simbolo || 'Q'} #{format('%.2f', total.to_d)}"
  end

  def preparar_dte!
    Dte::Infile::BuildFromFactura.new(self).call
  end

  def certificar_infile!
    preparar_dte!.certificar!
  end

  def dte_certificado?
    dte&.certificado? || false
  end

  def numero_visible
    numero.presence || "Pendiente INFILE"
  end

  def serie_visible
    serie.presence || "Pendiente INFILE"
  end

  def receptor_nit
    cliente&.tax_id.presence || "CF"
  end

  def receptor_nombre
    cliente&.billing_name.presence || cliente_nombre.presence || cliente&.nombre.presence || "Consumidor Final"
  end

  def receptor_direccion
    cliente&.billing_address.presence || "Ciudad"
  end

  private

  def sincronizar_cliente_nombre
    self.cliente_nombre = cliente.billing_name.presence || cliente.nombre if cliente.present? && cliente_nombre.blank?
  end

  def calcular_total_desde_detalles
    detalles = factura_detalles.reject(&:marked_for_destruction?)
    return if detalles.empty?

    self.total = detalles.sum { |detalle| detalle.total.to_d }
  end
end
