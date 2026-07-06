module ProductosServiciosHelper
  def moneda_para_registro(registro, producto_servicio = nil)
    registro.try(:moneda) || producto_servicio&.moneda
  end

  def moneda_simbolo_producto(producto_servicio)
    producto_servicio.moneda&.simbolo.presence || "Q"
  end

  def moneda_nombre_producto(producto_servicio)
    producto_servicio.moneda&.nombre.presence || "Moneda no definida"
  end

  def monto_producto(producto_servicio, valor)
    return "-" if valor.blank?

    number_to_currency(
      valor,
      unit: moneda_simbolo_producto(producto_servicio),
      precision: 2,
      delimiter: ",",
      separator: ".",
      format: "%u %n"
    )
  end

  def etiqueta_documento_producto(documento)
    "#{documento.filename} · #{number_to_human_size(documento.byte_size)}"
  end

  def monto_en_moneda(moneda, valor)
    return "-" if valor.blank?

    number_to_currency(
      valor,
      unit: moneda&.simbolo.presence || "Q",
      precision: 2,
      delimiter: ",",
      separator: ".",
      format: "%u %n"
    )
  end

  def totales_por_moneda(registros, atributo:, producto_servicio: nil)
    registros.each_with_object({}) do |registro, acumulado|
      moneda = moneda_para_registro(registro, producto_servicio)
      llave = moneda&.id || "sin_moneda"
      acumulado[llave] ||= { moneda: moneda, total: 0.to_d }
      acumulado[llave][:total] += registro.public_send(atributo).to_d
    end.values
  end

  def total_costos_producto(producto_servicio)
    costos = producto_servicio.producto_servicio_costos.reject(&:marked_for_destruction?).select(&:activo?)
    return producto_servicio.costo_base if costos.empty?

    moneda_referencia_id = producto_servicio.moneda_id
    costos
      .select { |costo| moneda_referencia_id.blank? || costo.moneda_id.blank? || costo.moneda_id == moneda_referencia_id }
      .sum { |costo| costo.monto.to_d }
  end

  def total_precios_producto(producto_servicio)
    precios = producto_servicio.producto_servicio_precios.reject(&:marked_for_destruction?).select(&:activo?)
    return producto_servicio.precio_base if precios.empty?

    moneda_referencia_id = producto_servicio.moneda_id
    precios
      .select { |precio| moneda_referencia_id.blank? || precio.moneda_id.blank? || precio.moneda_id == moneda_referencia_id }
      .sum { |precio| precio.precio.to_d }
  end

  def margen_promedio_producto(producto_servicio)
    precios = producto_servicio.producto_servicio_precios.reject(&:marked_for_destruction?).select(&:activo?)
    margenes = precios.filter_map { |precio| precio.margen&.to_d }
    return producto_servicio.margen_objetivo if margenes.empty?

    (margenes.sum / margenes.size).round(2)
  end

  def resumen_totales_por_moneda(registros, atributo:, producto_servicio: nil)
    totales_por_moneda(registros, atributo: atributo, producto_servicio: producto_servicio).map do |item|
      moneda = item[:moneda]
      "#{moneda&.simbolo.presence || 'Q'} #{number_with_precision(item[:total], precision: 2, delimiter: ',', separator: '.')}"
    end.join(" · ")
  end

  def tono_estado_cotizacion(cotizacion)
    case cotizacion.estado
    when "aprobada", "firmada"
      "success"
    when "enviada"
      "primary"
    when "rechazada", "cancelada"
      "danger"
    else
      "info"
    end
  end

  def fecha_cotizacion(cotizacion)
    l(cotizacion.created_at.to_date, format: :long)
  end

  def product_type_label(producto_servicio)
    producto_servicio.product_type.to_s.humanize.presence || "-"
  end

  def client_type_label(cliente)
    cliente.client_type.to_s.humanize.presence || "-"
  end
end
