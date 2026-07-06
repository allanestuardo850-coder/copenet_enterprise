class Proyecto < ApplicationRecord
  ESTADOS = %w[pendiente_inicio en_ejecucion cerrado cancelado].freeze

  belongs_to :cliente
  belongs_to :cotizacion
  belongs_to :expediente_cliente

  validates :nombre, :estado, presence: true
  validates :estado, inclusion: { in: ESTADOS }
  validates :cotizacion_id, uniqueness: true
end
