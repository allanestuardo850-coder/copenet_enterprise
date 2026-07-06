class Company < ApplicationRecord
  HEX_COLOR_REGEX = /\A#?(?:[A-F0-9]{3}|[A-F0-9]{6})\z/i

  has_one_attached :logo
  has_one_attached :quote_logo
  has_many :producto_servicios, dependent: :nullify

  attr_accessor :remove_logo, :remove_quote_logo

  validates :notification_email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_blank: true
  validates :quote_contact_email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_blank: true
  validates :quote_website_url,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) },
            allow_blank: true
  validates :web,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) },
            allow_blank: true
  validates :correo_comercial,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_blank: true
  validates :color_primario, :color_secundario, :color_acento,
            format: { with: HEX_COLOR_REGEX, message: "debe ser un color hexadecimal válido" },
            allow_blank: true
  validates :quote_table_header_color, :quote_contact_text_color,
            format: { with: HEX_COLOR_REGEX, message: "debe ser un color hexadecimal válido" },
            allow_blank: true

  after_commit :purge_quote_logo_if_marked

  def quote_title_display
    quote_title.presence || "Propuesta Comercial"
  end

  def quote_subtitle_display
    quote_subtitle.presence || "Documento comercial generado desde el catálogo maestro del servicio."
  end

  def quote_intro_display
    quote_intro_text.presence || "Agradecemos el interés mostrado en nuestros productos y servicios. Presentamos una propuesta comercial estructurada para evaluación y autorización."
  end

  def quote_closing_display
    quote_closing_text.presence || "Quedamos a su disposición para ampliar cualquier punto de esta propuesta, validar alcances finales y preparar la activación comercial correspondiente."
  end

  def quote_terms_display
    quote_terms_text.presence || "Los valores presentados están sujetos a validación comercial, vigencia de la oferta y formalización contractual."
  end

  def quote_contact_display_name
    quote_contact_name.presence || "Equipo Comercial"
  end

  def quote_contact_display_role
    quote_contact_role.presence || "Atención Comercial"
  end

  def quote_contact_display_email
    quote_contact_email.presence || correo_comercial.presence || notification_email.presence || email
  end

  def quote_contact_display_phone
    quote_contact_phone.presence || phone
  end

  def quote_display_url
    quote_website_url.presence || web.presence || "https://copenet.com.gt"
  end

  def quote_display_format_name
    quote_format_name.presence || "Propuesta Comercial"
  end

  def quote_signature_display_name
    quote_signature_name.presence || quote_contact_display_name
  end

  def quote_signature_display_role
    quote_signature_role.presence || quote_contact_display_role
  end

  def quote_table_header_color_display
    normalizar_hex(quote_table_header_color.presence || "#E8F0FF")
  end

  def quote_contact_text_color_display
    normalizar_hex(quote_contact_text_color.presence || "#0B2D66")
  end

  def branding_primary_color_display
    normalizar_hex(color_primario.presence || "#2458E6")
  end

  def branding_secondary_color_display
    normalizar_hex(color_secundario.presence || "#0B2D66")
  end

  def branding_accent_color_display
    normalizar_hex(color_acento.presence || "#6EB8FF")
  end

  private

  def normalizar_hex(valor)
    valor.to_s.start_with?("#") ? valor.to_s : "##{valor}"
  end

  def purge_quote_logo_if_marked
    logo.purge_later if ActiveModel::Type::Boolean.new.cast(remove_logo) && logo.attached?
    return unless ActiveModel::Type::Boolean.new.cast(remove_quote_logo)
    return unless quote_logo.attached?

    quote_logo.purge_later
  end
end
