class Factura < ApplicationRecord
  ESTADOS = %w[borrador emitida enviada pagada anulada inactiva].freeze

  belongs_to :cliente, optional: true
  belongs_to :moneda, optional: true

  validates :numero, :cliente_nombre, :estado, presence: true
  validates :numero, uniqueness: true
  validates :estado, inclusion: { in: ESTADOS }
  validates :total, numericality: { greater_than_or_equal_to: 0 }

  before_validation :sincronizar_cliente_nombre

  scope :ordenadas, -> { order(fecha_emision: :desc, created_at: :desc) }
  scope :activas, -> { where(activo: true) }

  def total_formateado
    "#{moneda&.simbolo || 'Q'} #{format('%.2f', total.to_d)}"
  end

  private

  def sincronizar_cliente_nombre
    self.cliente_nombre = cliente.nombre if cliente.present? && cliente_nombre.blank?
  end
end
