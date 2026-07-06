require "open3"
require "tempfile"

module ProductosServicios
  class GeneradorCotizacionPdf
    PDF_TEXT_REPLACEMENTS = {
      "\u00A0" => " ",
      "\u2013" => "-",
      "\u2014" => "-",
      "\u2018" => "'",
      "\u2019" => "'",
      "\u201C" => '"',
      "\u201D" => '"',
      "\u2022" => "-",
      "\u2023" => "-",
      "\u2026" => "...",
      "\u25B8" => "-",
      "\u25E6" => "-",
      "\u25AA" => "-",
      "\u25CF" => "-"
    }.freeze

    SECTION_DEFINITIONS = [
      { key: :cargos_iniciales, titulo: "CARGOS INICIALES" },
      { key: :cargos_diarios, titulo: "CARGOS DIARIOS x TRANSACCION" },
      { key: :cargos_mensuales, titulo: "CARGOS MENSUALES" },
      { key: :cargos_evento, titulo: "CARGOS POR EVENTO" },
      { key: :servicios_complementarios, titulo: "SERVICIOS COMPLEMENTARIOS" }
    ].freeze

    CLIENTES_COPENET_REGEX = /(socio copenet|cliente copenet)/i
    RUBROS_INCLUIBLES_REGEX = /(implementacion|desarrollo|setup|parametrizacion)/i

    PRIMARY_FALLBACK = "173B67".freeze
    SECONDARY_FALLBACK = "EAF1F8".freeze
    ACCENT_FALLBACK = "2F80ED".freeze
    TEXT_PRIMARY = "1E293B".freeze
    TEXT_MUTED = "5B6574".freeze

    def initialize(producto_servicio:, cotizacion:, view_context:)
      @producto_servicio = producto_servicio
      @cotizacion = cotizacion
      @view_context = view_context
      @company = producto_servicio.company
    end

    def render
      Prawn::Document.new(page_size: "LETTER", margin: [48, 46, 62, 46]) do |pdf|
        configurar_documento(pdf)
        configurar_pie_pagina(pdf)
        render_portada(pdf)
        render_propuesta(pdf) if contenido_propuesta?
      end.render
    end

    private

    attr_reader :producto_servicio, :cotizacion, :view_context, :company

    def configurar_documento(pdf)
      Prawn::Fonts::AFM.hide_m17n_warning = true
      pdf.font("Helvetica")
      pdf.default_leading 3
    end

    def render_portada(pdf)
      render_branding_superior(pdf, fit: [158, 54], heading_size: 15)
      pdf.move_cursor_to(pdf.bounds.top - 52)

      pdf.fill_color TEXT_MUTED
      pdf.text safe_pdf_text("Guatemala, #{fecha_emision}"), size: 10, align: :right
      pdf.fill_color TEXT_PRIMARY
      pdf.move_down 34

      pdf.text safe_pdf_text("Señores"), size: 10
      pdf.text safe_pdf_text(valor(destinatario_empresa_pdf)), size: 11, style: :bold
      pdf.text safe_pdf_text("Atención: #{valor(destinatario_cotizacion)}"), size: 10
      pdf.text safe_pdf_text("Pte."), size: 10
      pdf.move_down 22

      pdf.text safe_pdf_text("Estimados señores:"), size: 10, style: :bold
      pdf.move_down 10

      portada_parrafos.each do |parrafo|
        pdf.text safe_pdf_text(parrafo), size: 10, align: :justify
        pdf.move_down 10
      end

      pdf.fill_color color_primario
      pdf.text safe_pdf_text(titulo_portada), size: 17, style: :bold
      pdf.fill_color TEXT_PRIMARY
      pdf.move_down 12

      portada_alcance.each do |parrafo|
        pdf.text safe_pdf_text(parrafo), size: 10, align: :justify
        pdf.move_down 10
      end

      render_resumen_ejecutivo(pdf)
      pdf.move_down 16
      pdf.text safe_pdf_text(cierre_carta), size: 10, align: :justify
      pdf.move_down 22
      pdf.text safe_pdf_text("Atentamente,"), size: 10
      pdf.move_down 30
      render_bloque_firma(pdf)
    end

    def render_resumen_ejecutivo(pdf)
      top = pdf.cursor
      altura = 78
      pdf.fill_color panel_background_color
      pdf.fill_rectangle [pdf.bounds.left, top], pdf.bounds.width, altura
      pdf.stroke_color border_color
      pdf.stroke_rectangle [pdf.bounds.left, top], pdf.bounds.width, altura

      pdf.fill_color color_primario
      pdf.text_box safe_pdf_text("Resumen Ejecutivo"), at: [pdf.bounds.left + 14, top - 12], width: 180, size: 10, style: :bold
      pdf.fill_color TEXT_MUTED
      pdf.text_box safe_pdf_text("Código, empresa que factura, vigencia y total comercial."), at: [pdf.bounds.left + 14, top - 28], width: 280, size: 8.5

      items = [
        ["Código", cotizacion.codigo],
        ["Empresa", empresa_facturadora],
        ["Vigencia", "#{valor(cotizacion.vigencia_dias, '15')} días"],
        ["Total", total_final_destacado]
      ]

      left = pdf.bounds.left + 14
      base_y = top - 48
      column_width = (pdf.bounds.width - 28) / 4.0

      items.each_with_index do |(label, value), index|
        x = left + (column_width * index)
        pdf.fill_color TEXT_MUTED
        pdf.text_box safe_pdf_text(label), at: [x, base_y], width: column_width - 8, size: 8, style: :bold
        pdf.fill_color index == 3 ? accent_color : TEXT_PRIMARY
        pdf.text_box safe_pdf_text(value), at: [x, base_y - 15], width: column_width - 8, size: 9.5, style: :bold
      end

      pdf.fill_color TEXT_PRIMARY
      pdf.move_down altura + 4
    end

    def render_propuesta(pdf)
      pdf.start_new_page
      render_branding_superior(pdf, fit: [120, 42], heading_size: 13)
      linea_marca_en(pdf, pdf.bounds.top - 52)
      pdf.move_cursor_to(pdf.bounds.top - 76)

      pdf.fill_color color_primario
      pdf.text safe_pdf_text("Propuesta de Servicios"), size: 18, style: :bold
      pdf.fill_color TEXT_PRIMARY
      pdf.text safe_pdf_text("Detalle de la Propuesta Comercial"), size: 10.5, style: :bold
      pdf.move_down 8
      pdf.text safe_pdf_text(resumen_anexo_texto), size: 9.2, align: :justify
      pdf.move_down 12

      render_datos_propuesta(pdf)

      numero_seccion = 1
      secciones_detalle.each do |seccion|
        render_seccion_tabla(pdf, numero_seccion, seccion[:titulo], seccion[:detalles])
        numero_seccion += 1
      end

      if detalles_financieros.any?
        render_resumen_financiero(pdf, numero_seccion)
        numero_seccion += 1
      end

      if condiciones_comerciales_presentes?
        render_condiciones_comerciales(pdf, numero_seccion)
      end
    end

    def render_datos_propuesta(pdf)
      data = [
        ["Código", cotizacion.codigo, "Estado", valor(cotizacion.estado)],
        ["Cliente", valor(cotizacion.cliente), "Contacto", valor(destinatario_cotizacion)],
        ["Empresa que factura", empresa_facturadora, "Moneda", moneda_label(producto_servicio.moneda)],
        ["Correo", valor(cotizacion.correo), "Teléfono", valor(cotizacion.telefono)],
        ["Fecha de emisión", fecha_emision, "Vigencia", "#{valor(cotizacion.vigencia_dias, '15')} días"],
        ["Producto o servicio", producto_servicio.nombre, "Modelo de cobro", valor(producto_servicio.modelo_cobro)],
        ["Total final", total_final_destacado, "Tipo", valor(producto_servicio.tipo_producto)]
      ]
      render_grid_datos(pdf, data)
    end

    def render_seccion_tabla(pdf, numero, titulo, detalles)
      encabezado_seccion(pdf, "#{numero}. #{titulo}")
      draw_tabla_cargos_header(pdf)
      detalles.each do |detalle|
        draw_cargo_row(pdf, detalle)
      end

      pdf.move_down 14
    end

    def render_resumen_financiero(pdf, numero)
      border = border_color
      primary = color_primario

      encabezado_seccion(pdf, "#{numero}. RESUMEN FINANCIERO")

      rows = [["MONEDA", "SUBTOTAL", "DESCUENTO", "TOTAL FINAL"]]
      resumen_financiero_por_moneda.each do |item|
        rows << [
          moneda_label(item[:moneda]),
          monto_en_moneda(item[:moneda], item[:subtotal]),
          monto_en_moneda(item[:moneda], item[:descuento]),
          monto_en_moneda(item[:moneda], item[:total_final])
        ]
      end

      pdf.table(
        safe_table_rows(rows),
        header: true,
        width: pdf.bounds.width,
        cell_style: {
          size: 9,
          padding: [8, 10],
          border_color: border,
          border_width: 0.6
        }
      ) do
        row(0).background_color = primary
        row(0).text_color = "FFFFFF"
        row(0).font_style = :bold
        columns(1..3).align = :right
        row(1..-1).background_color = "FFFFFF"
      end

      pdf.move_down 8
      pdf.fill_color accent_color
      pdf.text safe_pdf_text("TOTAL FINAL: #{total_final_destacado}"), size: 13, style: :bold, align: :right
      pdf.fill_color TEXT_PRIMARY

      if cotizacion.multimoneda?
        pdf.move_down 6
        pdf.text safe_pdf_text("El resumen financiero se presenta por moneda porque la cotización contiene cargos mixtos."), size: 8.5, color: TEXT_MUTED
      end

      pdf.move_down 14
    end

    def render_condiciones_comerciales(pdf, numero)
      encabezado_seccion(pdf, "#{numero}. CONDICIONES COMERCIALES")

      condiciones_comerciales.each do |parrafo|
        pdf.text safe_pdf_text("- #{parrafo}"), size: 9.5, align: :justify
        pdf.move_down 7
      end

      if company&.quote_footer_note.present?
        pdf.move_down 4
        pdf.fill_color TEXT_MUTED
        pdf.text safe_pdf_text(company.quote_footer_note), size: 8.5, align: :justify
        pdf.fill_color TEXT_PRIMARY
      end
    end

    def render_bloque_firma(pdf)
      pdf.fill_color color_primario
      pdf.text safe_pdf_text(nombre_contacto_pdf), size: 11, style: :bold
      pdf.fill_color TEXT_PRIMARY
      pdf.text safe_pdf_text(cargo_contacto_pdf), size: 10
      pdf.text safe_pdf_text(nombre_emisor_pdf), size: 10
      pdf.fill_color TEXT_MUTED
      pdf.text safe_pdf_text("#{correo_contacto_pdf} | #{telefono_contacto_pdf}"), size: 9.5, style: :italic
      pdf.fill_color TEXT_PRIMARY
      pdf.text safe_pdf_text("Anexo: Propuesta de servicios."), size: 10, style: :italic
    end

    def encabezado_seccion(pdf, texto)
      pdf.fill_color color_primario
      pdf.text safe_pdf_text(texto), size: 12, style: :bold
      pdf.fill_color accent_color
      pdf.fill_rectangle [pdf.bounds.left, pdf.cursor - 2], pdf.bounds.width, 2
      pdf.fill_color TEXT_PRIMARY
      pdf.move_down 12
    end

    def render_branding_superior(pdf, fit:, heading_size:)
      attachment = logo_pdf_attachment

      if attachment&.attached?
        attachment.open do |archivo|
          normalized_logo = normalizar_logo_para_pdf(archivo.path)
          pdf.image normalized_logo.path, at: [pdf.bounds.right - fit[0], pdf.bounds.top], fit: fit
        ensure
          normalized_logo&.close!
        end
      else
        pdf.fill_color color_primario
        pdf.font("Helvetica", style: :bold) do
          pdf.draw_text safe_pdf_text(nombre_emisor_pdf), at: [pdf.bounds.right - 200, pdf.bounds.top - 18], size: heading_size
        end
        if web_pdf_display.present?
          pdf.fill_color TEXT_MUTED
          pdf.draw_text safe_pdf_text(web_pdf_display), at: [pdf.bounds.right - 200, pdf.bounds.top - 34], size: 8.5
        end
      end
      pdf.fill_color TEXT_PRIMARY
    rescue StandardError
      pdf.fill_color color_primario
      pdf.font("Helvetica", style: :bold) do
        pdf.draw_text safe_pdf_text(nombre_emisor_pdf), at: [pdf.bounds.right - 200, pdf.bounds.top - 18], size: heading_size
      end
      pdf.fill_color TEXT_PRIMARY
    end

    def linea_marca(pdf)
      pdf.stroke_color color_primario
      pdf.line_width = 1.3
      pdf.stroke_horizontal_rule
      pdf.stroke_color border_color
      pdf.line_width = 1
    end

    def linea_marca_en(pdf, y)
      pdf.stroke_color color_primario
      pdf.line_width = 1.3
      pdf.stroke_line [pdf.bounds.left, y], [pdf.bounds.right, y]
      pdf.stroke_color border_color
      pdf.line_width = 1
    end

    def draw_tabla_cargos_header(pdf)
      top = pdf.cursor
      concept = concept_width(pdf)
      price = price_width(pdf)
      header_height = 24

      pdf.fill_color color_primario
      pdf.fill_rectangle [pdf.bounds.left, top], concept, header_height
      pdf.fill_rectangle [pdf.bounds.left + concept, top], price, header_height
      pdf.stroke_color border_color
      pdf.stroke_rectangle [pdf.bounds.left, top], concept, header_height
      pdf.stroke_rectangle [pdf.bounds.left + concept, top], price, header_height

      draw_multiline_text(pdf, ["CONCEPTO"], x: pdf.bounds.left + 10, y: top - 17, size: 9, color: "FFFFFF", style: :bold)
      draw_multiline_text(pdf, ["TARIFA"], x: pdf.bounds.left + concept + 10, y: top - 17, size: 9, color: "FFFFFF", style: :bold)
      pdf.move_down header_height
    end

    def draw_cargo_row(pdf, detalle)
      concept = concept_width(pdf)
      price = price_width(pdf)
      concept_lines = detalle_concepto_lines(detalle, concept - 20)
      price_lines = detalle_tarifa_lines(detalle, price - 20)
      row_height = [40, ([concept_lines.size, price_lines.size].max * 11) + 18].max

      asegurar_espacio_para_fila(pdf, row_height)

      top = pdf.cursor
      pdf.fill_color "FFFFFF"
      pdf.fill_rectangle [pdf.bounds.left, top], concept, row_height
      pdf.fill_rectangle [pdf.bounds.left + concept, top], price, row_height
      pdf.stroke_color border_color
      pdf.stroke_rectangle [pdf.bounds.left, top], concept, row_height
      pdf.stroke_rectangle [pdf.bounds.left + concept, top], price, row_height

      draw_multiline_text(pdf, concept_lines, x: pdf.bounds.left + 10, y: top - 20, size: 9, color: TEXT_PRIMARY)
      draw_multiline_text(pdf, price_lines, x: pdf.bounds.left + concept + 10, y: top - 20, size: 9, color: TEXT_PRIMARY, style: :bold)
      pdf.move_down row_height
    end

    def detalle_concepto_lines(detalle, width)
      lines = []
      lines.concat(wrapped_lines_for_width(detalle.descripcion, width))
      notas = []
      notas << detalle.producto_servicio_precio&.descripcion.to_s if detalle.producto_servicio_precio&.descripcion.present?
      notas << "Recurrencia: #{detalle.recurrencia}" if detalle.recurrencia.present?
      notas << "Moneda: #{moneda_label(detalle.moneda || producto_servicio.moneda)}"
      notas << "Incluido por condición comercial CopeNET" if detalle_incluido_por_condicion_copenet?(detalle)
      notas << "No facturable" unless detalle.facturable?
      notas.each do |nota|
        lines.concat(wrapped_lines_for_width(nota, width).map { |line| "  #{line}" })
      end
      lines
    end

    def detalle_tarifa_lines(detalle, width)
      lines = wrapped_lines_for_width(monto_en_moneda(detalle.moneda || producto_servicio.moneda, detalle.precio), width)
      if detalle_incluido_por_condicion_copenet?(detalle)
        lines.concat(wrapped_lines_for_width("Incluido", width))
      end
      lines
    end

    def asegurar_espacio_para_fila(pdf, row_height)
      return unless pdf.cursor < row_height + 70

      pdf.start_new_page
      render_branding_superior(pdf, fit: [120, 42], heading_size: 13)
      linea_marca_en(pdf, pdf.bounds.top - 52)
      pdf.move_cursor_to(pdf.bounds.top - 76)
      draw_tabla_cargos_header(pdf)
    end

    def render_fila_simple(pdf, filas)
      filas.each_with_index do |(etiqueta, valor_texto), index|
        top = pdf.cursor
        label_width = 150
        label_lines = wrapped_lines_for_width(etiqueta, label_width - 20)
        value_lines = wrapped_lines_for_width(valor_texto, pdf.bounds.width - label_width - 24)
        row_height = [42, ([label_lines.size, value_lines.size].max * 12) + 18].max

        pdf.fill_color index.even? ? panel_background_color : "FFFFFF"
        pdf.fill_rectangle [pdf.bounds.left, top], pdf.bounds.width, row_height
        pdf.stroke_color border_color
        pdf.stroke_rectangle [pdf.bounds.left, top], pdf.bounds.width, row_height

        draw_multiline_text(pdf, label_lines, x: pdf.bounds.left + 10, y: top - 22, size: 9, color: color_primario, style: :bold)
        draw_multiline_text(pdf, value_lines, x: pdf.bounds.left + label_width, y: top - 22, size: 9, color: TEXT_PRIMARY)

        pdf.fill_color TEXT_PRIMARY
        pdf.move_down row_height
      end
    end

    def render_grid_datos(pdf, filas)
      filas.each do |fila|
        render_doble_bloque_datos(pdf, [fila[0], fila[1]], [fila[2], fila[3]])
      end
      pdf.move_down 14
    end

    def render_doble_bloque_datos(pdf, izquierdo, derecho)
      gap = 12
      column_width = (pdf.bounds.width - gap) / 2.0
      top = pdf.cursor
      left_height = [46, block_height_for(column_width, izquierdo)].max
      right_height = [46, block_height_for(column_width, derecho)].max
      row_height = [left_height, right_height].max

      render_bloque_dato(pdf, pdf.bounds.left, top, column_width, row_height, izquierdo)
      render_bloque_dato(pdf, pdf.bounds.left + column_width + gap, top, column_width, row_height, derecho)
      pdf.move_down row_height + 10
    end

    def render_bloque_dato(pdf, x, top, width, height, contenido)
      etiqueta, valor_texto = contenido
      label_lines = wrapped_lines_for_width(etiqueta, width - 20)
      value_lines = wrapped_lines_for_width(valor_texto, width - 20)

      pdf.fill_color panel_background_color
      pdf.fill_rectangle [x, top], width, height
      pdf.stroke_color border_color
      pdf.stroke_rectangle [x, top], width, height

      draw_multiline_text(pdf, label_lines, x: x + 10, y: top - 20, size: 8.5, color: color_primario, style: :bold)
      value_start = top - 20 - (label_lines.size * 11) - 4
      draw_multiline_text(pdf, value_lines, x: x + 10, y: value_start, size: 9, color: TEXT_PRIMARY)
    end

    def block_height_for(width, contenido)
      etiqueta, valor_texto = contenido
      label_lines = wrapped_lines_for_width(etiqueta, width - 20)
      value_lines = wrapped_lines_for_width(valor_texto, width - 20)
      (label_lines.size * 11) + (value_lines.size * 12) + 24
    end

    def draw_multiline_text(pdf, lines, x:, y:, size:, color:, style: :normal)
      pdf.fill_color color
      pdf.font("Helvetica", style: style) do
        lines.each_with_index do |line, index|
          pdf.draw_text line, at: [x, y - (index * (size + 3))], size: size
        end
      end
      pdf.fill_color TEXT_PRIMARY
    end

    def wrapped_lines_for_width(text, width)
      max_chars = [(width / 6.6).floor, 12].max
      wrap_text(safe_pdf_text(text), max_chars)
    end

    def wrap_text(text, max_chars)
      lines = []
      text.to_s.split("\n").each do |paragraph|
        current = +""
        paragraph.split(/\s+/).each do |word|
          next if word.blank?

          if word.length > max_chars
            unless current.blank?
              lines << current
              current = +""
            end
            word.scan(/.{1,#{max_chars}}/).each { |chunk| lines << chunk }
            next
          end

          candidate = current.blank? ? word : "#{current} #{word}"
          if candidate.length <= max_chars
            current = candidate
          else
            lines << current unless current.blank?
            current = word
          end
        end
        lines << current unless current.blank?
        lines << "" if paragraph.blank?
      end
      lines.reject(&:nil?).presence || [""]
    end

    def configurar_pie_pagina(pdf)
      pdf.repeat(:all) do
        pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + 30], width: pdf.bounds.width, height: 26) do
          pdf.stroke_color border_color
          pdf.stroke_horizontal_rule
          pdf.move_down 6
          pdf.fill_color TEXT_MUTED
          pdf.text_box safe_pdf_text(footer_left_text), at: [0, 10], width: pdf.bounds.width - 110, size: 8.3
          pdf.text_box safe_pdf_text("Página #{pdf.page_number}"), at: [pdf.bounds.width - 90, 10], width: 90, align: :right, size: 8.3
          pdf.fill_color TEXT_PRIMARY
        end
      end
    end

    def secciones_detalle
      @secciones_detalle ||= SECTION_DEFINITIONS.filter_map do |definition|
        detalles = detalles_por_seccion[definition[:key]]
        next if detalles.blank?

        { titulo: definition[:titulo], detalles: detalles }
      end
    end

    def detalles_por_seccion
      @detalles_por_seccion ||= cotizacion.cotizacion_detalles.ordenados.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |detalle, memo|
        memo[identificar_seccion(detalle)] << detalle
      end
    end

    def identificar_seccion(detalle)
      seccion = detalle.seccion_cotizacion.to_s.downcase
      descripcion = detalle.descripcion.to_s.downcase
      recurrencia = detalle.recurrencia.to_s.downcase

      return :cargos_iniciales if seccion.include?("inicial")
      return :cargos_diarios if seccion.include?("diario") || descripcion.match?(/transacci|diari/)
      return :cargos_mensuales if seccion.include?("mensual") || recurrencia.include?("mensual") || recurrencia.include?("recurrente")
      return :cargos_evento if seccion.include?("evento")
      return :servicios_complementarios if seccion.include?("complement") || seccion.include?("opcional")
      return :cargos_diarios if descripcion.match?(/transacci|consumo/)

      :servicios_complementarios
    end

    def detalles_financieros
      @detalles_financieros ||= cotizacion.cotizacion_detalles.select(&:facturable?)
    end

    def resumen_financiero_por_moneda
      detalles_financieros.each_with_object({}) do |detalle, memo|
        moneda = detalle.moneda || producto_servicio.moneda
        key = moneda&.id || "sin_moneda"
        memo[key] ||= { moneda: moneda, subtotal: 0.to_d, descuento: 0.to_d, total_final: 0.to_d }
        memo[key][:subtotal] += detalle.precio.to_d
      end.values.map do |item|
        item[:descuento] = cotizacion.multimoneda? ? 0.to_d : descuento_para_total(item[:subtotal])
        item[:total_final] = (item[:subtotal] - item[:descuento]).round(2)
        item
      end
    end

    def contenido_propuesta?
      secciones_detalle.any? || condiciones_comerciales_presentes? || detalles_financieros.any?
    end

    def portada_parrafos
      [
        company&.quote_intro_text.presence || "Reciban un cordial saludo. Agradecemos el interés que han mostrado en nuestros productos y servicios.",
        "En atención a ello, presentamos la propuesta aplicable al proyecto cotizado, estructurada para evaluación, autorización y posterior transición al flujo operativo y de facturación."
      ].compact_blank
    end

    def portada_alcance
      textos = []
      textos << descripcion_producto_pdf if descripcion_producto_pdf.present?
      textos << producto_servicio.problema_resuelve.to_s if producto_servicio.problema_resuelve.present?
      textos << producto_servicio.caso_uso.to_s if producto_servicio.caso_uso.present?
      textos << producto_servicio.incluye_cotizacion.to_s if producto_servicio.incluye_cotizacion.present?
      textos << producto_servicio.requisitos_cierre_venta.to_s if producto_servicio.requisitos_cierre_venta.present?
      if textos.blank?
        textos << "La propuesta contempla la configuración comercial y operativa del concepto #{producto_servicio.nombre}, clasificado como #{producto_servicio.tipo_producto.to_s.downcase} con un modelo de cobro #{producto_servicio.modelo_cobro.to_s.downcase}."
        textos << "La empresa facturadora será #{empresa_facturadora} y la solución se presenta con el objetivo de facilitar su autorización, activación comercial y posterior control dentro de la plataforma."
      end
      textos << "El documento adjunto detalla los costos asociados a cada etapa del servicio: cargos iniciales, cargos diarios, cargos mensuales, cargos por evento y servicios complementarios cuando aplique."
      textos.compact_blank
    end

    def cierre_carta
      company&.quote_closing_display.presence || "Quedamos a su entera disposición para ampliar la información, aclarar cualquier duda sobre los conceptos incluidos o coordinar una reunión para revisar en detalle la propuesta ajustada a sus necesidades."
    end

    def titulo_portada
      producto_servicio.nombre.presence || company&.quote_title.presence || "Desarrollo e implementación de proyecto"
    end

    def condiciones_comerciales
      bloques = []
      bloques << "Vigencia de la oferta: #{valor(cotizacion.vigencia_dias, '15')} días calendario a partir de la fecha de emisión."
      bloques << "Forma de contacto comercial: #{correo_contacto_pdf} / #{telefono_contacto_pdf}." if correo_contacto_pdf.present? || telefono_contacto_pdf.present?
      bloques << "Empresa que facturará: #{empresa_facturadora}."
      bloques << company.quote_terms_text.to_s if company&.quote_terms_text.present?
      bloques << cotizacion.observaciones.to_s if cotizacion.observaciones.present?
      bloques.compact_blank
    end

    def condiciones_comerciales_presentes?
      condiciones_comerciales.any?
    end

    def detalle_incluido_por_condicion_copenet?(detalle)
      cliente_copenet? && !detalle.facturable? && detalle.descripcion.to_s.match?(RUBROS_INCLUIBLES_REGEX)
    end

    def cliente_copenet?
      cotizacion.cliente.to_s.match?(CLIENTES_COPENET_REGEX)
    end

    def total_final_destacado
      resumen_financiero_por_moneda.map { |item| monto_en_moneda(item[:moneda], item[:total_final]) }.join("  |  ")
    end

    def descuento_para_total(total)
      return 0.to_d if cotizacion.porcentaje_descuento.blank?

      (total.to_d * cotizacion.porcentaje_descuento.to_d / 100).round(2)
    end

    def descripcion_producto_pdf
      producto_servicio.descripcion.presence
    end

    def nombre_emisor_pdf
      company&.commercial_name.presence || company&.legal_name.presence || "CopeNET Enterprise"
    end

    def empresa_facturadora
      safe_pdf_text(nombre_emisor_pdf)
    end

    def destinatario_cotizacion
      cotizacion.contacto.presence || cotizacion.cliente
    end

    def destinatario_empresa_pdf
      cotizacion.cliente.presence || destinatario_cotizacion
    end

    def nombre_contacto_pdf
      company&.quote_signature_name.presence ||
        company&.quote_contact_name.presence ||
        "Equipo Comercial #{nombre_emisor_pdf}"
    end

    def cargo_contacto_pdf
      company&.quote_signature_role.presence ||
        company&.quote_contact_role.presence ||
        "Área Comercial"
    end

    def correo_contacto_pdf
      safe_pdf_text(
        company&.correo_comercial.presence ||
        company&.quote_contact_email.presence ||
        company&.notification_email.presence ||
        "comercial@copenet.com.gt"
      )
    end

    def telefono_contacto_pdf
      safe_pdf_text(company&.phone.presence || company&.quote_contact_phone.presence || "(+502) 2307-5406")
    end

    def web_pdf_display
      website = company&.web.presence || company&.quote_website_url.presence
      return if website.blank?

      safe_pdf_text(website.to_s.sub(%r{\Ahttps?://}i, ""))
    end

    def resumen_anexo_texto
      "A continuación se presenta el detalle de la propuesta comercial para #{valor(cotizacion.cliente)}, incluyendo cargos, recurrencias, moneda, condiciones y resumen financiero para autorización."
    end

    def footer_left_text
      [web_pdf_display, telefono_contacto_pdf, correo_contacto_pdf].compact_blank.join("   |   ")
    end

    def logo_pdf_attachment
      return company.logo if company&.logo&.attached?
      return company.quote_logo if company&.quote_logo&.attached?

      nil
    end

    def normalizar_logo_para_pdf(source_path)
      tempfile = Tempfile.new(["company-logo-pdf", ".jpg"])
      tempfile.binmode
      tempfile.close

      _stdout, stderr, status = Open3.capture3(
        "/usr/bin/sips",
        "-s", "format", "jpeg",
        source_path,
        "--out", tempfile.path
      )
      raise "No se pudo normalizar el logo para PDF: #{stderr}" unless status.success?

      tempfile
    rescue StandardError
      tempfile&.close!
      raise
    end

    def fecha_emision
      fecha = cotizacion.created_at&.to_date || Date.current
      I18n.l(fecha, format: :long)
    end

    def color_primario
      @color_primario ||= normalizar_hex(company&.color_primario, PRIMARY_FALLBACK)
    end

    def color_secundario
      @color_secundario ||= normalizar_hex(company&.color_secundario, SECONDARY_FALLBACK)
    end

    def accent_color
      @accent_color ||= normalizar_hex(company&.color_acento, ACCENT_FALLBACK)
    end

    def panel_background_color
      @panel_background_color ||= blend_hex(color_secundario, "FFFFFF", 0.82)
    end

    def border_color
      @border_color ||= blend_hex(color_primario, "FFFFFF", 0.84)
    end

    def normalizar_hex(valor, fallback)
      valor = valor.to_s.delete("#").presence || fallback
      valor.upcase
    end

    def blend_hex(color_a, color_b, ratio)
      ratio = ratio.to_f.clamp(0, 1)
      a = hex_to_rgb(color_a)
      b = hex_to_rgb(color_b)
      format(
        "%02X%02X%02X",
        ((a[0] * (1 - ratio)) + (b[0] * ratio)).round,
        ((a[1] * (1 - ratio)) + (b[1] * ratio)).round,
        ((a[2] * (1 - ratio)) + (b[2] * ratio)).round
      )
    end

    def hex_to_rgb(color)
      value = color.to_s.delete("#")
      value = value.chars.map { |char| "#{char}#{char}" }.join if value.length == 3
      [value[0, 2], value[2, 2], value[4, 2]].map { |part| part.to_i(16) }
    end

    def concept_width(pdf)
      pdf.bounds.width - price_width(pdf)
    end

    def price_width(pdf)
      [150, (pdf.bounds.width * 0.28).round].max
    end

    def monto_en_moneda(moneda, valor)
      return "-" if valor.blank?

      safe_pdf_text(
        view_context.number_to_currency(
          valor,
          unit: moneda&.simbolo.presence || "Q",
          precision: 2,
          delimiter: ",",
          separator: ".",
          format: "%u %n"
        )
      )
    end

    def moneda_label(moneda)
      safe_pdf_text([moneda&.simbolo, moneda&.nombre].compact.join(" - ").presence || "Sin moneda definida")
    end

    def valor(texto, fallback = "-")
      safe_pdf_text(texto.present? ? texto.to_s : fallback)
    end

    def safe_table_rows(rows)
      rows.map { |row| row.map { |cell| safe_pdf_text(cell) } }
    end

    def safe_pdf_text(text)
      normalized = text.to_s.unicode_normalize(:nfkc)
      PDF_TEXT_REPLACEMENTS.each do |source, target|
        normalized = normalized.gsub(source, target)
      end
      normalized
        .encode("Windows-1252", invalid: :replace, undef: :replace, replace: "")
        .encode("UTF-8", "Windows-1252", invalid: :replace, undef: :replace, replace: "")
    end
  end
end
