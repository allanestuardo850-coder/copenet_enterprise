class ProductoServicio < ApplicationRecord
  PRODUCT_TYPES = %w[
    software
    desarrollo
    implementacion
    licencia
    mensualidad
    hardware
    capacitacion
    consultoria
    servicios_profesionales
    viajes
    gastos
  ].freeze

  has_many_attached :documentos_comerciales
  has_many :cotizaciones, class_name: "Cotizacion", dependent: :destroy, inverse_of: :producto_servicio
  has_many :producto_servicio_costos, -> { ordenados }, dependent: :destroy, inverse_of: :producto_servicio
  has_many :producto_servicio_precios, -> { ordenados }, dependent: :destroy, inverse_of: :producto_servicio
  has_many :factura_detalles, dependent: :restrict_with_error

  accepts_nested_attributes_for :producto_servicio_costos,
                                allow_destroy: true,
                                reject_if: ->(attributes) do
                                  attributes["tipo_costo"].blank? &&
                                    attributes["nombre"].blank? &&
                                    attributes["descripcion"].blank? &&
                                    attributes["monto"].blank? &&
                                    attributes["recurrencia"].blank?
                                end
  accepts_nested_attributes_for :producto_servicio_precios,
                                allow_destroy: true,
                                reject_if: ->(attributes) do
                                  attributes["nombre"].blank? &&
                                    attributes["descripcion"].blank? &&
                                    attributes["precio"].blank? &&
                                    attributes["margen"].blank?
                                end

  TIPOS_PRODUCTO = [
    "Servicio",
    "Producto",
    "Licencia",
    "Equipo",
    "Comision",
    "Integracion",
    "Cargo administrativo",
    "Implementacion",
    "Soporte",
    "Servicio transaccional"
  ].freeze

  CATEGORIAS = [
    "Cobro recurrente",
    "Cobro variable",
    "Cobro unico",
    "Cobro transaccional",
    "Infraestructura",
    "Operaciones",
    "Tecnologia"
  ].freeze

  MODELOS_COBRO = [
    "Fijo",
    "Recurrente",
    "Variable",
    "Transaccional",
    "Hibrido"
  ].freeze

  ESTADOS_CATALOGO = ["Borrador", "Aprobado", "Inactivo"].freeze
  RECURRENCIAS = ["Semanal", "Quincenal", "Mensual", "Trimestral", "Semestral", "Anual"].freeze
  UNIDADES_COBRO = ["Transaccion", "Usuario", "Equipo", "Lote", "Hora", "Mes", "Implementacion"].freeze
  TIPOS_FACTURACION = ["Anticipada", "Vencida", "Inmediata", "Consolidada"].freeze
  NIVELES_SERVICIO = ["Basico", "Estándar", "Premium", "Critico"].freeze
  MODELOS_LIQUIDACION = ["Porcentaje", "Fija", "Escalonada", "Mixta"].freeze
  BASES_LIQUIDACION = ["Bruto", "Neto", "Cobrado"].freeze
  TIPOS_IMPUESTO = ["IVA", "Exento", "No afecto"].freeze

  belongs_to :moneda, optional: true
  belongs_to :company, optional: true

  before_validation :asignar_codigo_correlativo, on: :create
  before_validation :sincronizar_campos_copenet
  before_validation :normalizar_descuento
  before_validation :asignar_moneda_principal_desde_detalles
  before_validation :recalcular_precio_base_total
  before_validation :recalcular_costo_base_total
  after_update :registrar_cambios_copenet

  validates :codigo, :nombre, :tipo_producto, :categoria, :modelo_cobro, :estado_catalogo, presence: true
  validates :codigo, uniqueness: true, length: { maximum: 60 }
  validates :product_type, inclusion: { in: PRODUCT_TYPES }, allow_blank: true
  validates :nombre, length: { maximum: 180 }
  validates :problema_resuelve, :caso_uso, :incluye_cotizacion, :requisitos_cierre_venta,
            length: { maximum: 4000 },
            allow_blank: true
  validates :precio_base, :cantidad_minima, :cantidad_maxima, :costo_base, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :porcentaje_descuento_maximo, :porcentaje_liquidacion, :margen_objetivo,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            allow_blank: true
  validates :dia_cobro, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }, allow_blank: true
  validates :duracion_minima_meses, :orden_visual, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validates :recurrencia, presence: true, if: :es_recurrente?
  validates :unidad_cobro, presence: true, if: :requiere_consumo?
  validates :tipo_facturacion, presence: true, if: :facturable?
  validates :modelo_liquidacion, :base_liquidacion, presence: true, if: :liquidable?
  validates :tipo_impuesto, presence: true, if: :afecto_iva?

  validate :validar_vigencia
  validate :validar_cantidad_rango
  validate :validar_dependencias_cobro

  scope :orden_admin, -> { order(:orden_visual, :nombre, :codigo) }
  scope :disponibles_para_facturar, -> { where(activo: true, facturable: true).order(:nombre, :codigo) }

  def self.siguiente_codigo_para(year = Date.current.year)
    year = year.to_i
    ultimo_codigo = where("codigo LIKE ?", "CO-%-#{year}").order(:codigo).last&.codigo
    ultimo_correlativo = ultimo_codigo.to_s.match(/\ACO-(\d{5})-#{year}\z/).to_a[1].to_i

    format("CO-%<correlativo>05d-%<year>d", correlativo: ultimo_correlativo + 1, year: year)
  end

  def recalcular_totales_catalogo!
    precios_activos = producto_servicio_precios.activos.to_a
    costos_activos = producto_servicio_costos.activos.to_a
    moneda_referencia_id = moneda_id.presence ||
                           precios_activos.find(&:moneda_id?)&.moneda_id ||
                           costos_activos.find(&:moneda_id?)&.moneda_id

    self.moneda_id = moneda_referencia_id if moneda_id.blank? && moneda_referencia_id.present?
    self.precio_base = precios_activos
      .select { |precio| moneda_referencia_id.blank? || precio.moneda_id.blank? || precio.moneda_id == moneda_referencia_id }
      .sum { |precio| precio.precio.to_d }
    self.costo_base = costos_activos
      .select { |costo| moneda_referencia_id.blank? || costo.moneda_id.blank? || costo.moneda_id == moneda_referencia_id }
      .sum { |costo| costo.monto.to_d }

    margenes = precios_activos.filter_map { |precio| precio.margen&.to_d }
    self.margen_objetivo = margenes.any? ? (margenes.sum / margenes.size).round(2) : nil

    save!(validate: false)
  end

  def no_charge_for_copenet?
    ActiveModel::Type::Boolean.new.cast(self[:no_charge_for_copenet])
  end

  def allow_discount?
    ActiveModel::Type::Boolean.new.cast(self[:allow_discount])
  end

  def billable?
    ActiveModel::Type::Boolean.new.cast(self[:billable])
  end

  def visible_in_quote?
    ActiveModel::Type::Boolean.new.cast(self[:visible_in_quote])
  end

  private

  def asignar_codigo_correlativo
    self.codigo = self.class.siguiente_codigo_para((created_at || Time.current).year) if codigo.blank?
  end

  def normalizar_descuento
    return if permite_descuento?

    self.porcentaje_descuento_maximo = nil
  end

  def sincronizar_campos_copenet
    self.product_type = inferir_product_type if product_type.blank?

    if will_save_change_to_allow_discount? && !will_save_change_to_permitedescuento?
      self.permite_descuento = allow_discount
    else
      self.allow_discount = permite_descuento
    end

    if will_save_change_to_billable? && !will_save_change_to_facturable?
      self.facturable = billable
    else
      self.billable = facturable
    end

    if will_save_change_to_is_recurring_service? && !will_save_change_to_es_recurrente?
      self.es_recurrente = is_recurring_service
    else
      self.is_recurring_service = es_recurrente
    end

    self.visible_in_quote = true if self[:visible_in_quote].nil?
    self.is_license = product_type == "licencia" if self[:is_license].nil? && product_type.present?
    self.is_development = product_type == "desarrollo" if self[:is_development].nil? && product_type.present?
    self.is_implementation = product_type == "implementacion" if self[:is_implementation].nil? && product_type.present?
  end

  def inferir_product_type
    case tipo_producto.to_s.downcase
    when /licencia/
      "licencia"
    when /implement/
      "implementacion"
    when /servicio transaccional/
      "servicios_profesionales"
    when /producto|equipo/
      "hardware"
    else
      "software"
    end
  end

  def registrar_cambios_copenet
    return unless saved_change_to_no_charge_for_copenet?

    BitacoraEvento.registrar!(
      event_type: "producto.no_charge_for_copenet_changed",
      description: "Se actualizó la regla de no cobro para clientes CopeNET.",
      subject: self,
      metadata: {
        from: saved_change_to_no_charge_for_copenet.first,
        to: saved_change_to_no_charge_for_copenet.last
      }
    )
  end

  def asignar_moneda_principal_desde_detalles
    return if moneda_id.present?

    self.moneda_id = producto_servicio_precios.find { |precio| precio.moneda_id.present? }&.moneda_id ||
                     producto_servicio_costos.find { |costo| costo.moneda_id.present? }&.moneda_id
  end

  def recalcular_precio_base_total
    precios_activos = producto_servicio_precios.reject(&:marked_for_destruction?).select(&:activo?)
    if precios_activos.empty?
      self.precio_base = 0
      self.margen_objetivo = nil
      return
    end

    moneda_referencia_id = moneda_id.presence || precios_activos.find(&:moneda_id?)&.moneda_id
    self.moneda_id = moneda_referencia_id if moneda_id.blank? && moneda_referencia_id.present?
    self.precio_base = precios_activos
      .select { |precio| moneda_referencia_id.blank? || precio.moneda_id.blank? || precio.moneda_id == moneda_referencia_id }
      .sum { |precio| precio.precio.to_d }

    margenes = precios_activos.filter_map { |precio| precio.margen&.to_d }
    self.margen_objetivo = (margenes.sum / margenes.size).round(2) if margenes.any?
  end

  def recalcular_costo_base_total
    costos_activos = producto_servicio_costos.reject(&:marked_for_destruction?).select(&:activo?)
    if costos_activos.empty?
      self.costo_base = 0
      return
    end

    moneda_referencia_id = moneda_id.presence || costos_activos.find(&:moneda_id?)&.moneda_id
    self.moneda_id = moneda_referencia_id if moneda_id.blank? && moneda_referencia_id.present?
    self.costo_base = costos_activos
      .select { |costo| moneda_referencia_id.blank? || costo.moneda_id.blank? || costo.moneda_id == moneda_referencia_id }
      .sum { |costo| costo.monto.to_d }
  end

  def validar_vigencia
    return if fecha_inicio_vigencia.blank? || fecha_fin_vigencia.blank?
    return unless fecha_fin_vigencia < fecha_inicio_vigencia

    errors.add(:fecha_fin_vigencia, "debe ser mayor o igual a la fecha de inicio")
  end

  def validar_cantidad_rango
    return if cantidad_minima.blank? || cantidad_maxima.blank?
    return unless cantidad_maxima < cantidad_minima

    errors.add(:cantidad_maxima, "debe ser mayor o igual a la cantidad mínima")
  end

  def validar_dependencias_cobro
    if modelo_cobro == "Transaccional" && dia_cobro.present?
      errors.add(:dia_cobro, "no aplica para productos transaccionales")
    end

    if !es_recurrente? && recurrencia.present?
      errors.add(:recurrencia, "solo aplica cuando el producto es recurrente")
    end

    if permite_descuento? && porcentaje_descuento_maximo.blank?
      errors.add(:porcentaje_descuento_maximo, "debe indicarse cuando el descuento está habilitado")
    end
  end
end
