class ProductoServicioCosto < ApplicationRecord
  TIPOS_COSTO = [
    "Licencia",
    "Implementacion",
    "Soporte",
    "Operacion",
    "Infraestructura",
    "Comision",
    "Integracion",
    "Colateral",
    "Impuesto",
    "Logistica",
    "Otro"
  ].freeze

  RECURRENCIAS = [
    "Unico",
    "Semanal",
    "Quincenal",
    "Mensual",
    "Trimestral",
    "Semestral",
    "Anual",
    "Por evento"
  ].freeze

  belongs_to :producto_servicio, inverse_of: :producto_servicio_costos
  belongs_to :moneda, optional: true

  after_commit :sincronizar_producto_servicio

  validates :tipo_costo, :nombre, :recurrencia, presence: true
  validates :tipo_costo, inclusion: { in: TIPOS_COSTO }
  validates :recurrencia, inclusion: { in: RECURRENCIAS }
  validates :nombre, length: { maximum: 180 }
  validates :descripcion, length: { maximum: 1000 }, allow_blank: true
  validates :orden, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :monto, numericality: { greater_than_or_equal_to: 0 }

  scope :ordenados, -> { order(:orden, :id) }
  scope :activos, -> { where(activo: true) }

  private

  def sincronizar_producto_servicio
    ProductoServicio.find_by(id: producto_servicio_id)&.recalcular_totales_catalogo!
  end
end
