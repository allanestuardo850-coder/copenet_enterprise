class Cotizacion < ApplicationRecord
  self.table_name = "cotizaciones"

  attr_accessor :current_usuario

  ESTADOS = %w[borrador enviada aprobada firmada rechazada cancelada].freeze

  belongs_to :producto_servicio, class_name: "ProductoServicio", inverse_of: :cotizaciones
  belongs_to :cliente_registro, class_name: "Cliente", foreign_key: :cliente_id, optional: true
  has_many :cotizacion_detalles, -> { ordenados }, dependent: :destroy, inverse_of: :cotizacion

  accepts_nested_attributes_for :cotizacion_detalles,
                                allow_destroy: true,
                                reject_if: ->(attributes) do
                                  attributes["descripcion"].blank? &&
                                    attributes["precio"].blank? &&
                                    attributes["applied_price"].blank?
                                end

  before_validation :asignar_codigo_correlativo, on: :create
  before_validation :sincronizar_snapshot_cliente
  before_validation :normalizar_estado
  before_validation :calcular_totales
  before_validation :propagar_actor_a_detalles
  before_update :bloquear_edicion_de_firmada
  before_destroy :bloquear_eliminacion_de_firmada
  after_commit :registrar_cambio_estado, if: :saved_change_to_estado?
  after_commit :procesar_firma, if: :saved_change_to_estado?

  validates :codigo, presence: true, uniqueness: true
  validates :cliente, :contacto, :correo, :precio_base, :vigencia_dias, presence: true
  validates :correo, format: { with: URI::MailTo::EMAIL_REGEXP, message: "debe tener un formato válido" }
  validates :vigencia_dias, numericality: { only_integer: true, greater_than: 0 }
  validates :precio_base, :monto_descuento, :precio_final, numericality: { greater_than_or_equal_to: 0 }
  validates :porcentaje_descuento, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_blank: true
  validates :estado, inclusion: { in: ESTADOS }
  validate :requerir_al_menos_un_item
  validate :validar_descuento_en_multimoneda
  validate :requerir_cliente_relacionado, on: :create
  validate :requerir_motivo_anulacion, if: -> { estado == "cancelada" }

  scope :recientes, -> { order(created_at: :desc, id: :desc) }

  def self.siguiente_codigo_para(year = Date.current.year)
    year = year.to_i
    ultimo_codigo = where("codigo LIKE ?", "CTZ-%-#{year}").order(:codigo).last&.codigo
    ultimo_correlativo = ultimo_codigo.to_s.match(/\ACTZ-(\d{5})-#{year}\z/).to_a[1].to_i

    format("CTZ-%<correlativo>05d-%<year>d", correlativo: ultimo_correlativo + 1, year: year)
  end

  def monedas_detalle_ids
    cotizacion_detalles.reject(&:marked_for_destruction?).filter_map(&:moneda_id).uniq
  end

  def multimoneda?
    monedas_detalle_ids.size > 1
  end

  def firmada?
    estado == "firmada"
  end

  def aprobada?
    estado == "aprobada"
  end

  def borrador?
    estado == "borrador"
  end

  def total_facturable
    cotizacion_detalles.reject(&:marked_for_destruction?).sum(&:monto_facturable)
  end

  def total_no_cobrado_copenet
    cotizacion_detalles.reject(&:marked_for_destruction?).sum(&:valor_no_cobrado)
  end

  def costo_interno_total
    cotizacion_detalles.reject(&:marked_for_destruction?).sum { |detalle| detalle.internal_cost.to_d }
  end

  def margen_estimado
    total_facturable - costo_interno_total
  end

  def nombre_proyecto_sugerido
    base = [producto_servicio.nombre, cliente_registro&.display_name || self[:cliente]].compact.join(" · ")
    "Proyecto #{base}"
  end

  def checklist_inicial_proyecto
    [
      "Validar contrato",
      "Confirmar documentación firmada",
      "Asignar responsables",
      "Preparar facturación"
    ].join("\n")
  end

  def documentacion_relacionada_proyecto
    [observaciones, alcance_personalizado].compact.reject(&:blank?).join("\n\n")
  end

  private

  def asignar_codigo_correlativo
    self.codigo = self.class.siguiente_codigo_para((created_at || Time.current).year) if codigo.blank?
  end

  def calcular_totales
    detalles_vigentes = cotizacion_detalles.reject(&:marked_for_destruction?)
    self.precio_base = if detalles_vigentes.any?
                         detalles_vigentes.sum { |detalle| detalle.applied_price.to_d.nonzero? || detalle.precio.to_d }
                       else
                         precio_base.to_d
                       end
    self.porcentaje_descuento = nil if porcentaje_descuento.blank? || porcentaje_descuento.to_d <= 0
    self.monto_descuento = if porcentaje_descuento.present? && !multimoneda?
                             (precio_base * porcentaje_descuento.to_d / 100).round(2)
                           else
                             0
                           end
    self.precio_final = (precio_base - monto_descuento.to_d).round(2)
  end

  def requerir_al_menos_un_item
    return if cotizacion_detalles.reject(&:marked_for_destruction?).any?

    errors.add(:base, "Debes agregar al menos un ítem a la cotización")
  end

  def validar_descuento_en_multimoneda
    return unless multimoneda? && porcentaje_descuento.present? && porcentaje_descuento.to_d.positive?

    errors.add(:porcentaje_descuento, "no puede aplicarse de forma global cuando la cotización mezcla monedas")
  end

  def requerir_cliente_relacionado
    return if cliente_id.present?

    errors.add(:cliente_id, "debe seleccionarse para aplicar reglas comerciales y expediente")
  end

  def sincronizar_snapshot_cliente
    return unless cliente_registro.present?

    self[:cliente] = cliente_registro.display_name
    self.contacto = cliente_registro.contacto_principal if contacto.blank?
    self.correo = cliente_registro.email if correo.blank?
    self.telefono = cliente_registro.telefono if telefono.blank?
  end

  def normalizar_estado
    estado_normalizado = estado.to_s.strip.downcase
    self.estado = estado_normalizado.presence || "borrador"
    self.approved_at ||= Time.current if estado == "aprobada"
    self.signed_at ||= Time.current if estado == "firmada"
  end

  def propagar_actor_a_detalles
    cotizacion_detalles.each { |detalle| detalle.current_usuario = current_usuario }
  end

  def bloquear_edicion_de_firmada
    return unless estado_in_database == "firmada"
    return if changes_to_save.except("updated_at").blank?

    errors.add(:base, "La cotización firmada no puede modificarse directamente. Debes crear una nueva versión.")
    throw(:abort)
  end

  def bloquear_eliminacion_de_firmada
    return unless firmada?

    errors.add(:base, "La cotización firmada no puede eliminarse. Debes anularla con motivo.")
    throw(:abort)
  end

  def registrar_cambio_estado
    BitacoraEvento.registrar!(
      event_type: "cotizacion.estado_changed",
      description: "La cotización cambió de estado a #{estado}.",
      subject: self,
      cliente: cliente_registro,
      cotizacion: self,
      metadata: {
        from: saved_change_to_estado.first,
        to: saved_change_to_estado.last
      }
    )
  end

  def procesar_firma
    return unless firmada?

    Cotizaciones::ProcesadorFirma.new(cotizacion: self).call
  end

  def requerir_motivo_anulacion
    return if cancellation_reason.present?

    errors.add(:cancellation_reason, "debe indicarse al anular una cotización")
  end
end
