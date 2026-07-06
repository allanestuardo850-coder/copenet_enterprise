class ExpedienteClientesController < ApplicationController
  before_action :cargar_cliente_y_expediente
  before_action :cargar_contexto, only: [:show, :actualizar_documentos]

  def show
    @current_page = :clientes
    @tab_activa = params[:tab].presence || "resumen"
  end

  def actualizar_documentos
    documentos = documentos_params[:documentos].to_a.reject(&:blank?)

    if documentos.empty?
      @current_page = :clientes
      @tab_activa = "documentos"
      flash.now[:alert] = "Selecciona al menos un archivo para incorporarlo al expediente."
      render :show, status: :unprocessable_entity
      return
    end

    @expediente_cliente.documentos.attach(documentos)
    registrar_documentos_agregados!(documentos)

    redirect_to expediente_cliente_path(@cliente, tab: "documentos"), notice: "Documentación agregada correctamente al expediente."
  rescue ActiveRecord::RecordInvalid => e
    @current_page = :clientes
    @tab_activa = "documentos"
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :show, status: :unprocessable_entity
  end

  private

  def cargar_cliente_y_expediente
    @cliente = Cliente.find(params[:id])
    @expediente_cliente = @cliente.expediente!
  end

  def cargar_contexto
    @cotizaciones = @cliente.cotizaciones.includes(:producto_servicio, :cotizacion_detalles).recientes
    @proyectos = @expediente_cliente.proyectos.includes(:cotizacion).order(created_at: :desc)
    @actividad = BitacoraEvento.where(cliente: @cliente).includes(:usuario, :cotizacion, :proyecto).recientes.limit(12)
    @documentos = @expediente_cliente.documentos.attachments.includes(:blob).order(created_at: :desc)
    @cotizacion_principal = @cotizaciones.detect { |cotizacion| %w[firmada aprobada enviada].include?(cotizacion.estado) } || @cotizaciones.first
    @cotizaciones_por_estado = Cotizacion::ESTADOS.index_with do |estado|
      @cotizaciones.count { |cotizacion| cotizacion.estado == estado }
    end
  end

  def documentos_params
    params.fetch(:expediente_cliente, {}).permit(documentos: [])
  end

  def registrar_documentos_agregados!(documentos)
    BitacoraEvento.registrar!(
      event_type: "expediente.documentos_added",
      description: "Se agregaron documentos al expediente del cliente.",
      subject: @expediente_cliente,
      cliente: @cliente,
      metadata: {
        cantidad: documentos.size,
        documentos: documentos.map(&:original_filename).join(", ")
      }
    )
  end
end
