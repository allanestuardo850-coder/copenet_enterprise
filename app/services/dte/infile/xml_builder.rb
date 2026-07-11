require "builder"

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
      xml.Item("BienOServicio" => "S", "NumeroLinea" => "1") do
        xml.Cantidad "1"
        xml.UnidadMedida "UND"
        xml.Descripcion dte.descripcion
        xml.PrecioUnitario format_decimal(dte.monto)
        xml.Precio format_decimal(dte.monto)
        xml.Descuento "0.00000"
        xml.Impuestos do
          xml.Impuesto do
            xml.NombreCorto "IVA"
            xml.CodigoUnidadGravable "1"
            xml.MontoGravable format_decimal(monto_gravable)
            xml.MontoImpuesto format_decimal(monto_iva)
          end
        end
        xml.Total format_decimal(dte.monto)
      end
    end
  end

  def totales(xml)
    xml.Totales do
      xml.TotalImpuestos do
        xml.TotalImpuesto("NombreCorto" => "IVA", "TotalMontoImpuesto" => format_decimal(monto_iva))
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

  def monto_gravable
    dte.monto.to_d / (BigDecimal("1") + IVA_RATE)
  end

  def monto_iva
    dte.monto.to_d - monto_gravable
  end

  def format_decimal(value)
    format("%.5f", value.to_d.round(5))
  end
end
