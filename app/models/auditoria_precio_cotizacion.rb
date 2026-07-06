class AuditoriaPrecioCotizacion < ApplicationRecord
  belongs_to :cotizacion
  belongs_to :cotizacion_detalle
  belongs_to :usuario, optional: true

  validates :new_applied_price, :original_price, presence: true

  scope :recientes, -> { order(changed_at: :desc, id: :desc) }
end
