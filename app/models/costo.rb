class Costo < ApplicationRecord
  ESTADOS = %w[registrado pendiente aprobado inactivo].freeze
  CLASIFICACIONES = ["Operativo", "Administrativo", "Infraestructura", "Servicio", "Otro"].freeze

  belongs_to :moneda, optional: true

  validates :concepto, :estado, presence: true
  validates :estado, inclusion: { in: ESTADOS }
  validates :monto, numericality: { greater_than_or_equal_to: 0 }

  scope :ordenados, -> { order(fecha: :desc, created_at: :desc) }
  scope :activos, -> { where(activo: true) }

  def monto_formateado
    "#{moneda&.simbolo || 'Q'} #{format('%.2f', monto.to_d)}"
  end
end
