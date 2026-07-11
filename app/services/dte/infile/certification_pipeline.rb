class Dte::Infile::CertificationPipeline
  def initialize(dte)
    @dte = dte
  end

  def call
    return failure!("El DTE ya fue certificado.") if dte.certificado?
    return failure!("La empresa emisora no tiene configuración INFILE completa.") unless dte.company.infile_configurada?

    xml = Dte::Infile::XmlBuilder.new(dte).call
    dte.update!(xml_sin_firmar: xml, estado: "pendiente_certificar")

    firma = client.firmar(xml)
    return persist_error!("Error al firmar XML en INFILE.", firma) unless resultado_exitoso?(firma)

    xml_firmado = archivo_firmado(firma)
    return persist_error!("INFILE no devolvió XML firmado.", firma) if xml_firmado.blank?

    dte.update!(xml_firmado: xml_firmado, estado: "firmado", request_payload: firma)

    certificacion = client.certificar(dte, xml_firmado)
    return persist_error!("Error al certificar DTE en INFILE.", certificacion) unless resultado_exitoso?(certificacion)

    body = certificacion[:body]
    dte.update!(
      estado: "certificado",
      uuid: body["uuid"] || body["UUID"],
      serie: body["serie"] || body["Serie"],
      numero: body["numero"] || body["Numero"],
      fecha_certificacion: Time.current,
      response_payload: body,
      errores_fel: {}
    )
    sincronizar_factura_certificada!
    { resultado: true, dte: dte }
  end

  private

  attr_reader :dte

  def client
    @client ||= Dte::Infile::Client.new(dte.company)
  end

  def resultado_exitoso?(response)
    response[:ok] && ActiveModel::Type::Boolean.new.cast(response[:body]["resultado"])
  end

  def archivo_firmado(response)
    response[:body]["archivo"].presence || response[:body]["xml_dte"].presence
  end

  def persist_error!(message, response = {})
    dte.update!(
      estado: "error_fel",
      errores_fel: { mensaje: message, respuesta: response },
      response_payload: response[:body] || {}
    )
    { resultado: false, dte: dte, mensaje: message }
  end

  def sincronizar_factura_certificada!
    dte.factura.update!(
      serie: dte.serie,
      numero: dte.numero,
      estado: "emitida"
    )
  end

  def failure!(message)
    { resultado: false, dte: dte, mensaje: message }
  end
end
