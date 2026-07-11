class Dte < ApplicationRecord
  ESTADOS = %w[pendiente_certificar firmado certificado error_fel anulado].freeze

  belongs_to :factura
  belongs_to :company

  validates :certificador, :tipo_dte, :estado, :identificador, :nit_receptor,
            :nombre_receptor, :moneda, :descripcion, presence: true
  validates :identificador, uniqueness: true
  validates :estado, inclusion: { in: ESTADOS }
  validates :monto, numericality: { greater_than_or_equal_to: 0 }

  scope :recientes, -> { order(created_at: :desc) }

  def certificado?
    estado == "certificado" && uuid.present?
  end

  def error?
    estado == "error_fel"
  end

  def certificable?
    !certificado? && estado != "anulado"
  end

  def certificar!
    Dte::Infile::CertificationPipeline.new(self).call
  end
end
