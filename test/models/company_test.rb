require "test_helper"

class CompanyTest < ActiveSupport::TestCase
  test "permite correos de contacto y notificacion validos" do
    company = Company.new(
      commercial_name: "Copenet",
      correo_comercial: "comercial@copenet.com.gt",
      notification_email: "notificaciones@copenet.com.gt",
      quote_contact_email: "comercial@copenet.com.gt"
    )

    assert company.valid?
  end

  test "rechaza correos invalidos en notificacion y contacto comercial" do
    company = Company.new(
      commercial_name: "Copenet",
      correo_comercial: "correo-invalido",
      notification_email: "correo-invalido",
      quote_contact_email: "sin-formato"
    )

    assert_not company.valid?
    assert_includes company.errors[:correo_comercial], "is invalid"
    assert_includes company.errors[:notification_email], "is invalid"
    assert_includes company.errors[:quote_contact_email], "is invalid"
  end

  test "expone fallbacks comerciales para cotizacion" do
    company = Company.new(
      commercial_name: "Copenet",
      correo_comercial: "comercial@copenet.com.gt",
      web: "https://copenet.com.gt",
      email: "info@copenet.com.gt",
      phone: "+502 2222-0000",
      color_primario: "#2458E6",
      color_secundario: "#0B2D66",
      color_acento: "#6EB8FF"
    )

    assert_equal "Equipo Comercial", company.quote_contact_display_name
    assert_equal "Atención Comercial", company.quote_contact_display_role
    assert_equal "comercial@copenet.com.gt", company.quote_contact_display_email
    assert_equal "+502 2222-0000", company.quote_contact_display_phone
    assert_equal "https://copenet.com.gt", company.quote_display_url
    assert_equal "Propuesta Comercial", company.quote_display_format_name
    assert_equal "Propuesta Comercial", company.quote_title_display
    assert_equal "Documento comercial generado desde el catálogo maestro del servicio.", company.quote_subtitle_display
    assert_equal "Los valores presentados están sujetos a validación comercial, vigencia de la oferta y formalización contractual.", company.quote_terms_display
    assert_equal "Equipo Comercial", company.quote_signature_display_name
    assert_equal "Atención Comercial", company.quote_signature_display_role
    assert_equal "#2458E6", company.branding_primary_color_display
    assert_equal "#0B2D66", company.branding_secondary_color_display
    assert_equal "#6EB8FF", company.branding_accent_color_display
    assert_equal "#E8F0FF", company.quote_table_header_color_display
    assert_equal "#0B2D66", company.quote_contact_text_color_display
  end

  test "normaliza colores hexadecimales de branding comercial" do
    company = Company.new(
      commercial_name: "Copenet",
      quote_table_header_color: "DCEBFF",
      quote_contact_text_color: "2458E6"
    )

    assert company.valid?
    assert_equal "#DCEBFF", company.quote_table_header_color_display
    assert_equal "#2458E6", company.quote_contact_text_color_display
  end
end
