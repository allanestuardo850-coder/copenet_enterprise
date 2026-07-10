class Cobro < ApplicationRecord
  ESTADOS = %w[en_gestion cobrado vencido pendiente inactivo].freeze

  belongs_to :cliente, optional: true
  belongs_to :moneda, optional: true

  validates :referencia, :cliente_nombre, :estado, presence: true
  validates :referencia, uniqueness: true
  validates :estado, inclusion: { in: ESTADOS }
  validates :monto, numericality: { greater_than_or_equal_to: 0 }

  before_validation :sincronizar_cliente_nombre

  scope :ordenados, -> { order(fecha_vencimiento: :asc, created_at: :desc) }
  scope :activos, -> { where(activo: true) }

  def monto_formateado
    "#{moneda&.simbolo || 'Q'} #{format('%.2f', monto.to_d)}"
  end

  private

  def sincronizar_cliente_nombre
    self.cliente_nombre = cliente.nombre if cliente.present? && cliente_nombre.blank?
  end
end
