require "base64"
require "json"
require "net/http"
require "uri"

class Dte::Infile::Client
  DEFAULT_SIGNER_URL = "https://signer-emisores.feel.com.gt/sign_solicitud_firmas/firma_xml"
  DEFAULT_CERTIFIER_URL = "https://certificador.feel.com.gt/fel/certificacion/v2/dte"

  def initialize(company)
    @company = company
  end

  def firmar(xml, anulacion: false)
    post_json(
      signer_url,
      {
        llave: company.infile_signature_prefix,
        archivo: Base64.strict_encode64(xml),
        alias: company.infile_signature_prefix,
        es_anulacion: anulacion ? "S" : "N"
      }
    )
  end

  def certificar(dte, xml_firmado)
    post_json(
      certifier_url,
      {
        nit_emisor: company.tax_id.to_s.delete("-"),
        correo_copia: company.notification_email.to_s,
        xml_dte: xml_firmado
      },
      headers: {
        "usuario" => company.infile_prefix.to_s,
        "llave" => company.infile_key.to_s,
        "identificador" => dte.identificador
      }
    )
  end

  private

  attr_reader :company

  def signer_url
    ENV.fetch("INFILE_SIGNER_URL", DEFAULT_SIGNER_URL)
  end

  def certifier_url
    ENV.fetch("INFILE_CERTIFIER_URL", DEFAULT_CERTIFIER_URL)
  end

  def post_json(url, payload, headers: {})
    uri = URI.parse(url)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    headers.each { |key, value| request[key] = value }
    request.body = payload.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    parsed_body = JSON.parse(response.body.presence || "{}")
    {
      ok: response.is_a?(Net::HTTPSuccess),
      status: response.code.to_i,
      body: parsed_body
    }
  rescue JSON::ParserError
    { ok: false, status: response&.code.to_i, body: { "raw_body" => response&.body.to_s } }
  rescue StandardError => e
    { ok: false, status: nil, body: { "error" => e.message } }
  end
end
