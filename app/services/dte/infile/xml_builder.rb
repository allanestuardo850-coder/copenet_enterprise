require "builder"
require "ostruct"

class Dte::Infile::XmlBuilder
  IVA_RATE = BigDecimal("0.12")

  def initialize(dte)
    @dte = dte
  end

  def call
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.instruct!(:xml, version: "1.0", encoding: "UTF-8")
    xml.GTDocumento("xmlns" => "http://www.sat.gob.gt/dte/fel/0.2.0", "Version" => "0.1") do
      xml.SAT("ClaseDocumento" => "dte") do
        xml.DTE("ID" => "DatosCertificados") do
          xml.DatosEmision("ID" => "DatosEmision") do
            datos_generales(xml)
            emisor(xml)
            receptor(xml)
            frases(xml)
            items(xml)
            totales(xml)
          end
        end
        adenda(xml)
      end
    end
  end

  private

  attr_reader :dte

  def datos_generales(xml)
    xml.DatosGenerales(
      "CodigoMoneda" => dte.moneda,
      "FechaHoraEmision" => fecha_emision,
      "Tipo" => dte.tipo_dte
    )
  end

  def emisor(xml)
    company = dte.company
    xml.Emisor(
      "AfiliacionIVA" => company.vat_affiliation.presence || "GEN",
      "CodigoEstablecimiento" => company.fel_scenario_code.presence || "1",
      "CorreoEmisor" => company.notification_email.presence || company.email.to_s,
      "NITEmisor" => company.tax_id.to_s.delete("-"),
      "NombreComercial" => company.commercial_name.presence || company.legal_name.to_s,
      "NombreEmisor" => company.legal_name.presence || company.commercial_name.to_s
    ) do
      xml.DireccionEmisor do
        xml.Direccion company.address.presence || "Ciudad"
        xml.CodigoPostal "01001"
        xml.Municipio "Guatemala"
        xml.Departamento "Guatemala"
        xml.Pais "GT"
      end
    end
  end

  def receptor(xml)
    xml.Receptor(
      "CorreoReceptor" => dte.correo_receptor.to_s,
      "IDReceptor" => dte.nit_receptor.to_s.delete("-").presence || "CF",
      "NombreReceptor" => dte.nombre_receptor
    ) do
      xml.DireccionReceptor do
        xml.Direccion "Ciudad"
        xml.CodigoPostal "01001"
        xml.Municipio "Guatemala"
        xml.Departamento "Guatemala"
        xml.Pais "GT"
      end
    end
  end

  def frases(xml)
    xml.Frases do
      xml.Frase("CodigoEscenario" => dte.company.fel_scenario_code.presence || "1", "TipoFrase" => "1")
    end
  end

  def items(xml)
    xml.Items do
      detalles.each_with_index do |detalle, index|
        xml.Item("BienOServicio" => "S", "NumeroLinea" => (index + 1).to_s) do
          xml.Cantidad format_decimal(detalle.cantidad)
          xml.UnidadMedida "UND"
          xml.Descripcion detalle.descripcion
          xml.PrecioUnitario format_decimal(detalle.precio_unitario)
          xml.Precio format_decimal(detalle.subtotal)
          xml.Descuento "0.00000"
          xml.Impuestos do
            xml.Impuesto do
              xml.NombreCorto "IVA"
              xml.CodigoUnidadGravable detalle.afecto_iva? ? "1" : "2"
              xml.MontoGravable format_decimal(monto_gravable(detalle.total, detalle.afecto_iva?))
              xml.MontoImpuesto format_decimal(monto_iva(detalle.total, detalle.afecto_iva?))
            end
          end
          xml.Total format_decimal(detalle.total)
        end
      end
    end
  end

  def totales(xml)
    xml.Totales do
      xml.TotalImpuestos do
        xml.TotalImpuesto("NombreCorto" => "IVA", "TotalMontoImpuesto" => format_decimal(total_iva))
      end
      xml.GranTotal format_decimal(dte.monto)
    end
  end

  def adenda(xml)
    xml.Adenda do
      xml.COPENET do
        xml.IDENTIFICADOR dte.identificador
        xml.ORIGEN "Copenet Enterprise"
      end
    end
  end

  def fecha_emision
    (dte.factura.fecha_emision&.to_time || Time.current).iso8601
  end

  def detalles
    @detalles ||= begin
      factura_detalles = dte.factura.factura_detalles.to_a
      factura_detalles.presence || [OpenStruct.new(
        cantidad: 1,
        descripcion: dte.descripcion,
        precio_unitario: dte.monto,
        subtotal: dte.monto,
        total: dte.monto,
        afecto_iva?: true
      )]
    end
  end

  def monto_gravable(monto, afecto_iva)
    return monto.to_d unless afecto_iva

    monto.to_d / (BigDecimal("1") + IVA_RATE)
  end

  def monto_iva(monto, afecto_iva)
    return 0.to_d unless afecto_iva

    monto.to_d - monto_gravable(monto, afecto_iva)
  end

  def total_iva
    detalles.sum { |detalle| monto_iva(detalle.total, detalle.afecto_iva?) }
  end

  def format_decimal(value)
    format("%.5f", value.to_d.round(5))
  end
end
