class Cliente < ApplicationRecord
  CLIENT_TYPES = %w[copenet no_socio interno distribuidor partner].freeze

  has_many :cotizaciones, dependent: :restrict_with_error
  has_many :proyectos, dependent: :restrict_with_error
  has_one :expediente_cliente, dependent: :destroy
  has_many :facturas, dependent: :restrict_with_error

  validates :nombre, :client_type, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :client_type, inclusion: { in: CLIENT_TYPES }

  before_validation :sincronizar_bandera_copenet
  after_commit :asegurar_expediente!, on: :create
  after_update :registrar_cambios_relevantes

  scope :ordenados, -> { order(:nombre, :id) }
  scope :activos, -> { where(activo: true) }
  scope :copenet, -> { where(is_copenet_client: true) }

  def display_name
    nombre
  end

  def billing_display_name
    billing_name.presence || nombre
  end

  def tax_id_display
    tax_id.presence || "CF"
  end

  def expediente!
    expediente_cliente || create_expediente_cliente!(
      titulo: "Expediente de #{display_name}",
      estado: "activo"
    )
  end

  private

  def asegurar_expediente!
    expediente!
  end

  def sincronizar_bandera_copenet
    self.is_copenet_client = true if client_type == "copenet"
  end

  def registrar_cambios_relevantes
    if saved_change_to_client_type?
      BitacoraEvento.registrar!(
        event_type: "cliente.client_type_changed",
        description: "Se actualizó el tipo de cliente.",
        subject: self,
        cliente: self,
        metadata: {
          from: saved_change_to_client_type.first,
          to: saved_change_to_client_type.last
        }
      )
    end

    return unless saved_change_to_is_copenet_client?

    BitacoraEvento.registrar!(
      event_type: "cliente.copenet_flag_changed",
      description: "Se actualizó la bandera CopeNET del cliente.",
      subject: self,
      cliente: self,
      metadata: {
        from: saved_change_to_is_copenet_client.first,
        to: saved_change_to_is_copenet_client.last
      }
    )
  end
end
