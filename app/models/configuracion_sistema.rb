class ConfiguracionSistema < ApplicationRecord
  HEX_COLOR_REGEX = /\A#?(?:[A-F0-9]{3}|[A-F0-9]{6})\z/i

  has_one_attached :logo_principal
  has_one_attached :logo_login
  has_one_attached :logo_footer

  attr_accessor :eliminar_logo_principal, :eliminar_logo_login, :eliminar_logo_footer

  validates :nombre_plataforma, :nombre_principal, :nombre_secundario, :login_eyebrow,
            :login_titulo, :login_subtitulo, :promo_titulo, :promo_descripcion,
            :promo_boton_texto, :promo_boton_url, :footer_logo_texto, :footer_logo_etiqueta,
            :placeholder_busqueda, :loader_mensaje, :pdf_titulo, :pdf_subtitulo,
            :pdf_intro_texto, :pdf_cierre_texto, :pdf_firma_nombre, :pdf_firma_cargo,
            presence: true
  validates :color_primario, :color_secundario, :color_acento, :color_sidebar_desde,
            :color_sidebar_hasta, :color_boton_texto,
            format: { with: HEX_COLOR_REGEX, message: "debe ser un color hexadecimal válido" }

  before_validation :aplicar_defaults
  after_commit :depurar_logos_marcados

  def self.actual
    first || new(default_attributes)
  end

  def self.default_attributes
    {
      nombre_plataforma: "Copenet Enterprise",
      nombre_principal: "COPENET",
      nombre_secundario: "ENTERPRISE",
      login_eyebrow: "Copenet Enterprise",
      login_titulo: "Control empresarial con una base moderna y segura",
      login_subtitulo: "Plataforma empresarial para administración, costos, cobros y control operativo.",
      promo_titulo: "Mejora tu experiencia",
      promo_descripcion: "Descubre todas las funcionalidades avanzadas de Copenet Enterprise.",
      promo_boton_texto: "Ver planes",
      promo_boton_url: "#",
      footer_logo_texto: "VISA",
      footer_logo_etiqueta: "Visa",
      placeholder_busqueda: "Buscar empresas, cuentas o reportes",
      loader_mensaje: "Cargando plataforma...",
      pdf_titulo: "Propuesta Comercial Autorizable",
      pdf_subtitulo: "Documento comercial generado desde el catálogo maestro del servicio.",
      pdf_intro_texto: "Agradecemos el interés mostrado en nuestros productos y servicios. Por medio del presente documento compartimos una propuesta comercial estructurada a partir del catálogo maestro del servicio, separando cargos iniciales, mensuales, recurrentes y complementarios cuando aplique.",
      pdf_cierre_texto: "Quedamos a su disposición para ampliar cualquier punto de esta propuesta, validar alcances finales y preparar la activación comercial correspondiente. Una vez autorizada, esta cotización puede continuar su preparación hacia el flujo de facturación.",
      pdf_firma_nombre: "Equipo Comercial Copenet",
      pdf_firma_cargo: "Dirección Comercial",
      color_primario: "#2458e6",
      color_secundario: "#0b2d66",
      color_acento: "#6eb8ff",
      color_sidebar_desde: "#0a2146",
      color_sidebar_hasta: "#08172e",
      color_boton_texto: "#ffffff"
    }
  end

  private

  def aplicar_defaults
    self.class.default_attributes.each do |atributo, valor|
      self[atributo] = valor if self[atributo].blank?
    end
  end

  def depurar_logos_marcados
    logo_principal.purge_later if ActiveModel::Type::Boolean.new.cast(eliminar_logo_principal) && logo_principal.attached?
    logo_login.purge_later if ActiveModel::Type::Boolean.new.cast(eliminar_logo_login) && logo_login.attached?
    logo_footer.purge_later if ActiveModel::Type::Boolean.new.cast(eliminar_logo_footer) && logo_footer.attached?
  end
end
