class Dte::Infile::BuildFromFactura
  def initialize(factura)
    @factura = factura
  end

  def call
    dte = factura.dte || factura.build_dte
    dte.assign_attributes(attributes_for_dte(dte))
    dte.save!
    dte
  end

  private

  attr_reader :factura

  def attributes_for_dte(dte)
    {
      company: company,
      certificador: "infile",
      tipo_dte: "FACT",
      estado: dte.estado.presence || "pendiente_certificar",
      identificador: dte.identificador.presence || identificador,
      nit_receptor: nit_receptor,
      nombre_receptor: factura.receptor_nombre,
      correo_receptor: factura.cliente&.email,
      moneda: factura.moneda&.codigo.presence || "GTQ",
      descripcion: descripcion,
      monto: factura.total.to_d
    }
  end

  def company
    factura.company || Company.activas.order(:commercial_name, :legal_name).first ||
      raise(ArgumentError, "La factura necesita una empresa emisora para certificar DTE.")
  end

  def nit_receptor
    factura.receptor_nit
  end

  def descripcion
    factura.notas.presence || "Factura emitida por Copenet Enterprise"
  end

  def identificador
    [
      "COPENET",
      "FACT",
      factura.id || SecureRandom.hex(4),
      Time.current.strftime("%Y%m%d%H%M%S")
    ].join("-")
  end
end
