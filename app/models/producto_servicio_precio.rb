class ProductoServicioPrecio < ApplicationRecord
  RECURRENCIAS = [
    "Unico",
    "Mensual",
    "Recurrente",
    "Trimestral",
    "Semestral",
    "Anual",
    "Por evento",
    "Transaccional"
  ].freeze

  SECCIONES_COTIZACION = [
    "Cargo inicial",
    "Cargo mensual",
    "Cargo recurrente",
    "Cargo por evento",
    "Servicio complementario"
  ].freeze

  belongs_to :producto_servicio, inverse_of: :producto_servicio_precios
  belongs_to :moneda, optional: true
  has_many :factura_detalles, dependent: :restrict_with_error

  after_commit :sincronizar_producto_servicio

  validates :nombre, presence: true, length: { maximum: 180 }
  validates :descripcion, length: { maximum: 1000 }, allow_blank: true
  validates :precio, numericality: { greater_than_or_equal_to: 0 }
  validates :margen, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_blank: true
  validates :orden, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :recurrencia, inclusion: { in: RECURRENCIAS }
  validates :seccion_cotizacion, inclusion: { in: SECCIONES_COTIZACION }

  scope :ordenados, -> { order(:orden, :id) }
  scope :activos, -> { where(activo: true) }
  scope :cotizables, -> { where(cotizable: true) }
  scope :facturables, -> { where(facturable: true) }

  private

  def sincronizar_producto_servicio
    ProductoServicio.find_by(id: producto_servicio_id)&.recalcular_totales_catalogo!
  end
end
