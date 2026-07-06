module ApplicationHelper
  def configuracion_sistema_actual
    @configuracion_sistema_actual ||= ConfiguracionSistema.actual
  end

  def branding_texto(atributo, fallback = nil)
    valor = configuracion_sistema_actual.public_send(atributo)
    valor.present? ? valor : fallback
  end

  def branding_color(atributo, fallback)
    valor = configuracion_sistema_actual.public_send(atributo)
    valor.present? ? normalizar_hex(valor) : fallback
  end

  def branding_css_variables
    primario = branding_color(:color_primario, "#2458e6")
    secundario = branding_color(:color_secundario, "#0b2d66")
    acento = branding_color(:color_acento, "#6eb8ff")
    sidebar_desde = branding_color(:color_sidebar_desde, "#0a2146")
    sidebar_hasta = branding_color(:color_sidebar_hasta, "#08172e")
    boton_texto = branding_color(:color_boton_texto, "#ffffff")

    <<~CSS.html_safe
      <style>
        :root,
        html.theme-dark {
          --primary: #{primario};
          --primary-dark: #{secundario};
          --primary-soft: #{rgba_hex(primario, 0.12)};
          --info: #{acento};
          --brand-accent: #{acento};
          --brand-sidebar-from: #{sidebar_desde};
          --brand-sidebar-to: #{sidebar_hasta};
          --brand-button-text: #{boton_texto};
          --brand-promo-from: #{rgba_hex(acento, 0.24)};
          --brand-promo-to: #{rgba_hex(secundario, 0.42)};
          --brand-footer-from: #{secundario};
          --brand-footer-to: #{acento};
        }
      </style>
    CSS
  end

  def branding_image(attachment_name, css_class:, alt:)
    attachment = configuracion_sistema_actual.public_send(attachment_name)
    return unless attachment.attached?

    image_tag attachment, class: css_class, alt: alt
  end

  def branding_logo_attached?(attachment_name)
    configuracion_sistema_actual.public_send(attachment_name).attached?
  end

  private

  def normalizar_hex(valor)
    hex = valor.to_s.start_with?("#") ? valor.to_s : "##{valor}"
    hex
  end

  def rgba_hex(valor, alpha)
    hex = normalizar_hex(valor).delete("#")
    hex = hex.chars.map { |char| "#{char}#{char}" }.join if hex.length == 3
    rgb = hex.scan(/../).map { |pair| pair.to_i(16) }
    "rgba(#{rgb.join(', ')}, #{alpha})"
  end
end
