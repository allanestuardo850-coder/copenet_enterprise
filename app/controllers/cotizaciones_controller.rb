class CotizacionesController < ApplicationController
  before_action :set_cotizacion, only: %i[update actualizar_estado]

  def index
    @current_page = :cotizaciones
    @filtros = {
      query: params[:query].to_s.strip,
      estado: params[:estado].to_s.strip
    }

    @cotizaciones = Cotizacion.includes(:cliente_registro, producto_servicio: :moneda, cotizacion_detalles: :moneda).recientes
    @cotizaciones = aplicar_filtros(@cotizaciones)
  end

  def actualizar_estado
    @cotizacion.current_usuario = current_usuario

    if @cotizacion.update(estado_params)
      redirect_back fallback_location: cotizaciones_path,
                    status: :see_other,
                    notice: "Estado de cotización actualizado a #{@cotizacion.estado}."
    else
      redirect_back fallback_location: cotizaciones_path,
                    status: :see_other,
                    alert: @cotizacion.errors.full_messages.to_sentence
    end
  end

  def update
    @cotizacion.current_usuario = current_usuario

    if @cotizacion.update(cotizacion_params)
      redirect_to cotizacion_productos_servicio_path(@cotizacion.producto_servicio, cotizacion_id: @cotizacion.id),
                  status: :see_other,
                  notice: "Cotización actualizada correctamente."
    else
      redirect_to cotizacion_productos_servicio_path(@cotizacion.producto_servicio, cotizacion_id: @cotizacion.id, modo: "editar"),
                  status: :see_other,
                  alert: @cotizacion.errors.full_messages.to_sentence
    end
  end

  private

  def set_cotizacion
    @cotizacion = Cotizacion.find(params[:id])
  end

  def aplicar_filtros(scope)
    scope = scope.where(
      "codigo ILIKE :term OR cliente ILIKE :term OR contacto ILIKE :term OR correo ILIKE :term",
      term: "%#{@filtros[:query]}%"
    ) if @filtros[:query].present?

    scope = scope.where(estado: @filtros[:estado]) if @filtros[:estado].present?
    scope
  end

  def estado_params
    params.require(:cotizacion).permit(:estado, :signed_by, :workflow_notes, :cancellation_reason)
  end

  def cotizacion_params
    params.require(:cotizacion).permit(
      :cliente_id,
      :estado,
      :cliente,
      :contacto,
      :correo,
      :telefono,
      :vigencia_dias,
      :precio_base,
      :porcentaje_descuento,
      :alcance_personalizado,
      :observaciones,
      cotizacion_detalles_attributes: [
        :id,
        :producto_servicio_precio_id,
        :descripcion,
        :catalog_price,
        :applied_price,
        :internal_cost,
        :precio,
        :moneda_id,
        :recurrencia,
        :seccion_cotizacion,
        :facturable,
        :billing_authorized,
        :manual_price_override,
        :price_override_reason,
        :discount_amount,
        :discount_reason,
        :price_rule_applied,
        :orden,
        :_destroy
      ]
    )
  end
end
