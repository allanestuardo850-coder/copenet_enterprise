module ExpedienteClientesHelper
  def tono_cotizacion_por_estado(estado)
    case estado.to_s
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

  def tono_estado_expediente(expediente_cliente)
    case expediente_cliente.estado_operativo
    when "Listo para prefacturación"
      "success"
    when "Pendiente de documentación"
      "warning"
    when "Cotización en gestión"
      "primary"
    when "Sin cotización"
      "danger"
    else
      "info"
    end
  end

  def tono_estado_proyecto(proyecto)
    case proyecto.estado
    when "cerrado"
      "success"
    when "cancelado"
      "danger"
    when "en_ejecucion"
      "primary"
    else
      "warning"
    end
  end

  def titulo_evento_expediente(evento)
    case evento.event_type
    when "cotizacion.estado_changed"
      "Estado de cotización actualizado"
    when "cliente.client_type_changed"
      "Tipo de cliente actualizado"
    when "cliente.copenet_flag_changed"
      "Regla CopeNET actualizada"
    when "expediente.documentos_added"
      "Documentación agregada al expediente"
    else
      evento.description
    end
  end

  def detalle_evento_expediente(evento)
    case evento.event_type
    when "cotizacion.estado_changed"
      [
        evento.cotizacion&.codigo,
        evento.description
      ].compact.join(" · ")
    when "expediente.documentos_added"
      archivos = evento.metadata["documentos"]
      cantidad = evento.metadata["cantidad"]
      [cantidad.to_i.positive? ? "#{cantidad} archivos agregados" : nil, archivos].compact.join(" · ")
    else
      evento.description
    end
  end

  def tono_evento_expediente(evento)
    case evento.event_type
    when "cotizacion.estado_changed"
      tono_cotizacion_por_estado(evento.cotizacion&.estado || evento.metadata["to"])
    when "expediente.documentos_added"
      "info"
    when "cliente.client_type_changed", "cliente.copenet_flag_changed"
      "warning"
    else
      "primary"
    end
  end

  def fecha_evento_expediente(evento)
    l(evento.created_at, format: :short)
  end

  def etiqueta_documento_expediente(documento)
    "#{documento.filename} · #{number_to_human_size(documento.byte_size)}"
  end
end
