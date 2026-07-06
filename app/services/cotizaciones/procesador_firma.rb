module Cotizaciones
  class ProcesadorFirma
    def initialize(cotizacion:)
      @cotizacion = cotizacion
    end

    def call
      return unless cotizacion.firmada?

      expediente = cotizacion.cliente_registro&.expediente!
      return unless expediente

      proyecto = expediente.proyectos.find_or_initialize_by(cotizacion: cotizacion)
      proyecto.assign_attributes(
        cliente: cotizacion.cliente_registro,
        nombre: cotizacion.nombre_proyecto_sugerido,
        estado: proyecto.estado.presence || "pendiente_inicio",
        fecha_inicio: proyecto.fecha_inicio.presence || Date.current,
        monto_aprobado: cotizacion.precio_final,
        monto_facturable: cotizacion.total_facturable,
        costo_interno_estimado: cotizacion.costo_interno_total,
        margen_estimado: cotizacion.margen_estimado,
        checklist_asignable: cotizacion.checklist_inicial_proyecto,
        documentacion_relacionada: cotizacion.documentacion_relacionada_proyecto
      )
      proyecto.save!

      BitacoraEvento.registrar!(
        event_type: "cotizacion.proyecto_generado",
        description: "Se generó o actualizó automáticamente un proyecto desde una cotización firmada.",
        subject: proyecto,
        cliente: cotizacion.cliente_registro,
        cotizacion: cotizacion,
        proyecto: proyecto,
        metadata: {
          expediente_cliente_id: expediente.id
        }
      )
    end

    private

    attr_reader :cotizacion
  end
end
