class BitacoraEvento < ApplicationRecord
  belongs_to :subject, polymorphic: true, optional: true
  belongs_to :usuario, optional: true
  belongs_to :cliente, optional: true
  belongs_to :cotizacion, optional: true
  belongs_to :proyecto, optional: true

  validates :event_type, :description, presence: true

  scope :recientes, -> { order(created_at: :desc, id: :desc) }

  def self.registrar!(event_type:, description:, subject: nil, usuario: Current.usuario, cliente: nil, cotizacion: nil, proyecto: nil, metadata: {})
    create!(
      event_type: event_type,
      description: description,
      subject: subject,
      usuario: usuario,
      cliente: cliente,
      cotizacion: cotizacion,
      proyecto: proyecto,
      metadata: metadata
    )
  end
end
