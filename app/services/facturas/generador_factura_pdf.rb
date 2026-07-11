require "prawn"
require "prawn/table"

module Facturas
class GeneradorFacturaPdf
  PRIMARY = "07318F"
  ACCENT = "0098B8"
  TEXT = "071D55"
  MUTED = "526383"
  BORDER = "D8E2EE"
  SOFT = "F3F7FF"

  def initialize(factura)
    @factura = factura
  end

  def render
    Prawn::Document.new(page_size: "LETTER", margin: [42, 52, 54, 52]) do |pdf|
      pdf.font("Helvetica")
      header(pdf)
      customer_block(pdf)
      items_table(pdf)
      totals_block(pdf)
      metadata_block(pdf)
      certification_block(pdf)
      footer(pdf)
    end.render
  end

  private

  attr_reader :factura

  def header(pdf)
    top = pdf.cursor
    pdf.fill_color PRIMARY
    pdf.text_box "C", at: [pdf.bounds.left, top - 8], width: 42, size: 30, style: :bold, align: :center
    pdf.text_box company_name.upcase, at: [pdf.bounds.left + 52, top], width: 260, size: 26, style: :bold
    pdf.fill_color ACCENT
    pdf.text_box "NET", at: [pdf.bounds.left + 178, top], width: 90, size: 26, style: :bold
    pdf.fill_color MUTED
    pdf.text_box "Conectividad que impulsa tu mundo", at: [pdf.bounds.left + 54, top - 30], width: 260, size: 9

    pdf.fill_color PRIMARY
    pdf.text_box "FACTURA ELECTRÓNICA", at: [pdf.bounds.right - 210, top - 4], width: 210, size: 17, style: :bold, align: :right
    info_card(pdf, pdf.bounds.right - 205, top - 34, 205, 88, [
      ["Serie:", factura.serie_visible],
      ["No.:", factura.numero_visible],
      ["Número de autorización", dte_uuid]
    ])

    pdf.move_cursor_to(top - 78)
    pdf.fill_color TEXT
    pdf.text company_name, size: 10, style: :bold
    pdf.fill_color MUTED
    pdf.text company_address, size: 8.5, leading: 1
    pdf.move_down 5
    pdf.fill_color TEXT
    pdf.text "NIT: #{company_tax_id}  •  PBX: #{company_phone}", size: 8.5
    pdf.move_down 4
    pdf.fill_color MUTED
    pdf.text "#{company_email}     #{company_web}", size: 8.2
    pdf.fill_color TEXT
    pdf.move_down 20
  end

  def customer_block(pdf)
    top = pdf.cursor
    height = 72
    pdf.stroke_color BORDER
    pdf.fill_color "FFFFFF"
    pdf.rounded_rectangle [pdf.bounds.left, top], pdf.bounds.width, height, 7
    pdf.fill_and_stroke

    pdf.fill_color ACCENT
    pdf.rounded_rectangle [pdf.bounds.left, top], 130, height, 7
    pdf.fill
    pdf.fill_color "FFFFFF"
    pdf.text_box "NIT:", at: [pdf.bounds.left + 42, top - 24], width: 78, size: 9, style: :bold
    pdf.text_box factura.receptor_nit, at: [pdf.bounds.left + 42, top - 40], width: 78, size: 9

    pdf.fill_color PRIMARY
    pdf.text_box "Nombre:", at: [pdf.bounds.left + 155, top - 18], width: 220, size: 7.5, style: :bold
    pdf.fill_color TEXT
    pdf.text_box factura.receptor_nombre, at: [pdf.bounds.left + 155, top - 32], width: 250, size: 9
    pdf.fill_color PRIMARY
    pdf.text_box "Dirección:", at: [pdf.bounds.left + 155, top - 48], width: 220, size: 7.5, style: :bold
    pdf.fill_color TEXT
    pdf.text_box factura.receptor_direccion, at: [pdf.bounds.left + 155, top - 60], width: 250, size: 8.5

    pdf.fill_color PRIMARY
    pdf.text_box "Correo:", at: [pdf.bounds.left + 420, top - 28], width: 80, size: 7.5, style: :bold
    pdf.fill_color TEXT
    pdf.text_box factura.cliente&.email.presence || "-", at: [pdf.bounds.left + 420, top - 42], width: 155, size: 8.5
    pdf.move_down height + 18
  end

  def items_table(pdf)
    rows = [["Cantidad", "Descripción", "Precio unitario", "Valor"]]
    detalle_rows.each do |detalle|
      rows << [
        format_quantity(detalle.cantidad),
        detalle.descripcion,
        money(detalle.precio_unitario),
        money(detalle.total)
      ]
    end
    rows << ["", "", "", ""] while rows.size < 7

    pdf.table(rows, width: pdf.bounds.width, cell_style: { border_color: BORDER, size: 8.5, padding: [9, 8] }) do
      row(0).background_color = PRIMARY
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      column(0).width = 78
      column(2).width = 125
      column(3).width = 112
      columns(0).align = :center
      columns(2..3).align = :right
    end
    pdf.move_down 18
  end

  def totals_block(pdf)
    top = pdf.cursor
    left_width = pdf.bounds.width * 0.58
    right_width = pdf.bounds.width - left_width - 18

    panel(pdf, pdf.bounds.left, top, left_width, 82)
    pdf.fill_color PRIMARY
    pdf.text_box "Total en letras:", at: [pdf.bounds.left + 70, top - 28], width: left_width - 88, size: 8, style: :bold
    pdf.fill_color TEXT
    pdf.text_box total_en_letras, at: [pdf.bounds.left + 70, top - 44], width: left_width - 88, size: 9, style: :bold

    panel(pdf, pdf.bounds.left + left_width + 18, top, right_width, 82)
    pdf.fill_color PRIMARY
    pdf.text_box "Totales", at: [pdf.bounds.left + left_width + 32, top - 8], width: 70, size: 9, style: :bold
    pdf.fill_color TEXT
    pdf.text_box "Subtotal", at: [pdf.bounds.left + left_width + 36, top - 36], width: 90, size: 9
    pdf.text_box money(factura.total), at: [pdf.bounds.right - 110, top - 36], width: 95, size: 9, align: :right
    pdf.fill_color ACCENT
    pdf.text_box "TOTAL", at: [pdf.bounds.left + left_width + 36, top - 62], width: 90, size: 12, style: :bold
    pdf.text_box money(factura.total), at: [pdf.bounds.right - 110, top - 62], width: 95, size: 12, style: :bold, align: :right
    pdf.fill_color TEXT
    pdf.move_down 102
  end

  def metadata_block(pdf)
    rows = [
      ["Moneda", factura.moneda&.nombre.presence || "Quetzales (GTQ)"],
      ["Fecha y hora", factura.fecha_emision || Date.current],
      ["Método de pago", "Tarjeta"],
      ["Estado", factura.estado.humanize]
    ]
    pdf.table([rows.map(&:first), rows.map { |row| row.last.to_s }], width: pdf.bounds.width, cell_style: { border_color: BORDER, size: 8.2, padding: [10, 8] }) do
      row(0).font_style = :bold
      row(0).text_color = PRIMARY
      row(0).align = :center
      row(1).align = :center
    end
    pdf.move_down 16
  end

  def certification_block(pdf)
    top = pdf.cursor
    panel(pdf, pdf.bounds.left, top, pdf.bounds.width * 0.52, 74)
    pdf.fill_color PRIMARY
    pdf.text_box "Número de autorización:", at: [pdf.bounds.left + 12, top - 14], width: 140, size: 7.5, style: :bold
    pdf.text_box "Fecha y hora de certificación:", at: [pdf.bounds.left + 12, top - 30], width: 150, size: 7.5, style: :bold
    pdf.text_box "Certificador:", at: [pdf.bounds.left + 12, top - 46], width: 120, size: 7.5, style: :bold
    pdf.fill_color TEXT
    pdf.text_box dte_uuid, at: [pdf.bounds.left + 170, top - 14], width: 170, size: 7.5
    pdf.text_box certification_date, at: [pdf.bounds.left + 170, top - 30], width: 170, size: 7.5
    pdf.text_box "INFILE, S.A.", at: [pdf.bounds.left + 170, top - 46], width: 170, size: 7.5

    qr_x = pdf.bounds.left + pdf.bounds.width * 0.62
    pdf.stroke_color PRIMARY
    pdf.stroke_rectangle [qr_x, top], 58, 58
    7.times do |index|
      pdf.fill_color index.even? ? PRIMARY : ACCENT
      pdf.fill_rectangle [qr_x + 8 + (index * 6), top - 8 - ((index % 4) * 9)], 5, 5
    end
    pdf.fill_color PRIMARY
    pdf.text_box "Escanea el código QR", at: [qr_x + 76, top - 8], width: 160, size: 8, style: :bold
    pdf.fill_color MUTED
    pdf.text_box "Verifica la validez de esta factura electrónica en el portal SAT.", at: [qr_x + 76, top - 24], width: 160, size: 8
    pdf.fill_color TEXT
    pdf.move_down 88
  end

  def footer(pdf)
    pdf.canvas do
      pdf.fill_color PRIMARY
      pdf.fill_rectangle [0, 34], pdf.bounds.absolute_right + pdf.bounds.left, 34
      pdf.fill_color "FFFFFF"
      pdf.text_box "Este documento es una representación impresa de una Factura Electrónica.", at: [pdf.bounds.left, 22], width: 310, size: 8
      pdf.text_box "SUJETO A RETENCIÓN DEFINITIVA ISR", at: [pdf.bounds.right - 230, 22], width: 230, size: 8, align: :right
    end
  end

  def info_card(pdf, x, y, width, height, rows)
    panel(pdf, x, y, width, height)
    rows.each_with_index do |(label, value), index|
      offset = 14 + (index * 24)
      pdf.fill_color index == 2 ? PRIMARY : TEXT
      pdf.text_box label, at: [x + 12, y - offset], width: 86, size: 8.5, style: :bold
      pdf.text_box value.to_s, at: [x + 88, y - offset], width: width - 100, size: 8.2, style: :bold
    end
    pdf.fill_color TEXT
  end

  def panel(pdf, x, y, width, height)
    pdf.stroke_color BORDER
    pdf.fill_color "FFFFFF"
    pdf.rounded_rectangle [x, y], width, height, 7
    pdf.fill_and_stroke
  end

  def detalle_rows
    @detalle_rows ||= factura.factura_detalles.to_a.presence || [FacturaDetalle.new(descripcion: factura.notas.presence || "Servicio facturado", cantidad: 1, precio_unitario: factura.total, total: factura.total)]
  end

  def company
    @company ||= factura.company || Company.activas.order(:commercial_name, :legal_name).first
  end

  def company_name
    company&.commercial_name.presence || company&.legal_name.presence || "Copenet"
  end

  def company_address
    company&.address.presence || "Guatemala, Guatemala"
  end

  def company_tax_id
    company&.tax_id.presence || "-"
  end

  def company_phone
    company&.phone.presence || "-"
  end

  def company_email
    company&.email.presence || company&.notification_email.presence || "-"
  end

  def company_web
    company&.website.presence || "-"
  end

  def dte_uuid
    factura.dte&.uuid.presence || factura.dte&.identificador.presence || "Pendiente INFILE"
  end

  def certification_date
    factura.dte&.fecha_certificacion&.strftime("%d/%m/%Y %H:%M:%S") || "Pendiente"
  end

  def money(value)
    "#{factura.moneda&.simbolo || 'Q'} #{format('%.2f', value.to_d)}"
  end

  def format_quantity(value)
    decimal = value.to_d
    decimal.frac.zero? ? decimal.to_i.to_s : format("%.2f", decimal)
  end

  def total_en_letras
    entero = factura.total.to_d.floor
    "#{numero_en_espanol(entero).upcase} QUETZALES EXACTOS"
  end

  def numero_en_espanol(number)
    return "cero" if number.zero?
    return unidades[number] if number < 30
    return decenas[number] if decenas[number]
    return "#{decenas[(number / 10) * 10]} y #{unidades[number % 10]}" if number < 100 && number % 10 != 0
    return centenas[number] if centenas[number]
    return "#{centenas[(number / 100) * 100]} #{numero_en_espanol(number % 100)}" if number < 1000
    return "mil #{numero_en_espanol(number % 1000)}" if number < 2000
    return "#{numero_en_espanol(number / 1000)} mil #{numero_en_espanol(number % 1000)}" if number < 1_000_000

    number.to_s
  end

  def unidades
    @unidades ||= {
      1 => "uno", 2 => "dos", 3 => "tres", 4 => "cuatro", 5 => "cinco", 6 => "seis", 7 => "siete", 8 => "ocho", 9 => "nueve",
      10 => "diez", 11 => "once", 12 => "doce", 13 => "trece", 14 => "catorce", 15 => "quince", 16 => "dieciseis", 17 => "diecisiete",
      18 => "dieciocho", 19 => "diecinueve", 20 => "veinte", 21 => "veintiuno", 22 => "veintidos", 23 => "veintitres", 24 => "veinticuatro",
      25 => "veinticinco", 26 => "veintiseis", 27 => "veintisiete", 28 => "veintiocho", 29 => "veintinueve"
    }
  end

  def decenas
    @decenas ||= { 30 => "treinta", 40 => "cuarenta", 50 => "cincuenta", 60 => "sesenta", 70 => "setenta", 80 => "ochenta", 90 => "noventa" }
  end

  def centenas
    @centenas ||= { 100 => "cien", 200 => "doscientos", 300 => "trescientos", 400 => "cuatrocientos", 500 => "quinientos", 600 => "seiscientos", 700 => "setecientos", 800 => "ochocientos", 900 => "novecientos" }
  end
end
end
