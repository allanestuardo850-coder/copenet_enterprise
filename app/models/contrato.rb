class Contrato < ApplicationRecord
  ESTADOS = %w[borrador activo renovacion vencido inactivo].freeze
  TIPOS = ["Servicio", "Licencia", "Soporte", "Proyecto", "Otro"].freeze

  belongs_to :cliente, optional: true
  belongs_to :moneda, optional: true

  validates :codigo, :cliente_nombre, :estado, presence: true
  validates :codigo, uniqueness: true
  validates :estado, inclusion: { in: ESTADOS }
  validates :valor, numericality: { greater_than_or_equal_to: 0 }

  before_validation :sincronizar_cliente_nombre

  scope :ordenados, -> { order(fecha_fin: :asc, created_at: :desc) }
  scope :activos, -> { where(activo: true) }

  def valor_formateado
    "#{moneda&.simbolo || 'Q'} #{format('%.2f', valor.to_d)}"
  end

  private

  def sincronizar_cliente_nombre
    self.cliente_nombre = cliente.nombre if cliente.present? && cliente_nombre.blank?
  end
end
