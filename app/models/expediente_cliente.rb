class ExpedienteCliente < ApplicationRecord
  belongs_to :cliente
  has_many :proyectos, dependent: :destroy
  has_many_attached :documentos

  validates :titulo, :estado, presence: true

  delegate :cotizaciones, to: :cliente

  def cotizaciones_aprobadas
    cotizaciones.where(estado: %w[aprobada firmada])
  end

  def cotizaciones_firmadas
    cotizaciones.where(estado: "firmada")
  end

  def cotizaciones_en_gestion
    cotizaciones.where(estado: %w[borrador enviada aprobada])
  end

  def total_cotizado
    cotizaciones.sum(&:precio_final)
  end

  def total_facturable
    cotizaciones.sum(&:total_facturable)
  end

  def valor_entregado_sin_costo
    cotizaciones_firmadas.sum(&:total_no_cobrado_copenet)
  end

  def total_documentos
    documentos.attachments.size
  end

  def proyectos_activos
    proyectos.where(estado: %w[pendiente_inicio en_ejecucion])
  end

  def listo_para_prefacturacion?
    cotizaciones_firmadas.exists? && documentos.attached?
  end

  def estado_operativo
    return "Listo para prefacturación" if listo_para_prefacturacion?
    return "Pendiente de documentación" if cotizaciones_firmadas.exists? && !documentos.attached?
    return "Cotización en gestión" if cotizaciones_en_gestion.exists?
    return "Sin cotización" if cotizaciones.none?

    "En seguimiento"
  end
end
