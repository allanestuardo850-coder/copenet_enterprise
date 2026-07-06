class ProductosServiciosController < ApplicationController
  before_action :set_producto_servicio, only: %i[show edit update destroy cotizacion cotizacion_pdf agregar_precio agregar_costo]
  before_action :cargar_catalogos, only: %i[new create edit update show agregar_precio agregar_costo cotizacion cotizacion_pdf]
  before_action :cargar_cotizaciones, only: %i[cotizacion cotizacion_pdf]
  before_action :cargar_cotizaciones_realizadas, only: %i[show]
  before_action :preparar_formularios_show, only: %i[show agregar_precio agregar_costo]

  def index
    @current_page = :productos_servicios
    @filtros = {
      query: params[:query].to_s.strip,
      estado_catalogo: params[:estado_catalogo].to_s.strip,
      modelo_cobro: params[:modelo_cobro].to_s.strip
    }

    @producto_servicios = ProductoServicio.includes(:moneda, :company).orden_admin
    @producto_servicios = aplicar_filtros(@producto_servicios)
  end

  def show
    @current_page = :productos_servicios
  end

  def agregar_precio
    @current_page = :productos_servicios
    @tab_activa = "comercial"
    @nuevo_precio.assign_attributes(producto_servicio_precio_params)

    if @nuevo_precio.save
      redirect_to productos_servicio_path(@producto_servicio, tab: "comercial"), notice: "Precio comercial agregado correctamente."
    else
      @nuevo_costo ||= ProductoServicioCosto.new(
        producto_servicio: @producto_servicio,
        activo: true,
        moneda_id: @producto_servicio.moneda_id,
        recurrencia: "Unico",
        orden: @producto_servicio.producto_servicio_costos.size
      )
      render :show, status: :unprocessable_entity
    end
  end

  def agregar_costo
    @current_page = :productos_servicios
    @tab_activa = "costos"
    @nuevo_costo.assign_attributes(producto_servicio_costo_params)

    if @nuevo_costo.save
      redirect_to productos_servicio_path(@producto_servicio, tab: "costos"), notice: "Costo agregado correctamente."
    else
      @nuevo_precio ||= ProductoServicioPrecio.new(
        producto_servicio: @producto_servicio,
        activo: true,
        cotizable: true,
        facturable: true,
        orden: @producto_servicio.producto_servicio_precios.size,
        moneda_id: @producto_servicio.moneda_id,
        recurrencia: @producto_servicio.es_recurrente? ? (@producto_servicio.recurrencia.presence || "Mensual") : "Unico",
        seccion_cotizacion: @producto_servicio.es_recurrente? ? "Cargo mensual" : "Cargo inicial"
      )
      render :show, status: :unprocessable_entity
    end
  end

  def cotizacion
    @current_page = :productos_servicios
    @modo_edicion_cotizacion = modo_edicion_cotizacion?

    if request.post?
      @cotizacion = @producto_servicio.cotizaciones.build(cotizacion_params)
      @cotizacion.current_usuario = current_usuario

      if @cotizacion.save
        redirect_to cotizacion_productos_servicio_path(@producto_servicio, cotizacion_id: @cotizacion.id), notice: "Cotización generada correctamente."
      else
        preparar_detalles_cotizacion(@cotizacion, con_valores_base: false)
        @cotizacion_seleccionada = @cotizacion
        @mostrar_formulario_cotizacion = true
        render :cotizacion, status: :unprocessable_entity
      end
    else
      @mostrar_formulario_cotizacion = params[:modo] == "nueva" || @modo_edicion_cotizacion || @cotizacion_seleccionada.blank?
      @cotizacion = if @modo_edicion_cotizacion
                      @cotizacion_seleccionada
                    elsif @mostrar_formulario_cotizacion
                      construir_cotizacion_base
                    else
                      @cotizacion_seleccionada
                    end
    end
  end

  def cotizacion_pdf
    @current_page = :productos_servicios
    cotizacion = cotizacion_seleccionada

    unless cotizacion.present?
      redirect_to cotizacion_productos_servicio_path(@producto_servicio), alert: "Primero debes generar o seleccionar una cotización."
      return
    end

    pdf = ProductosServicios::GeneradorCotizacionPdf.new(
      producto_servicio: @producto_servicio,
      cotizacion: cotizacion,
      view_context: view_context
    ).render

    send_data pdf,
              filename: "cotizacion-#{cotizacion.codigo.downcase}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  def new
    @current_page = :productos_servicios
    @producto_servicio = ProductoServicio.new(
      codigo: ProductoServicio.siguiente_codigo_para,
      activo: true,
      estado_catalogo: "Borrador",
      facturable: true,
      visible_en_crm: true,
      visible_en_contratos: true,
      visible_en_expedientes: true,
      afecto_iva: true
    )
    preparar_precios_formulario
    preparar_costos_formulario
  end

  def create
    @current_page = :productos_servicios
    @producto_servicio = ProductoServicio.new(producto_servicio_params)

    if @producto_servicio.save
      redirect_to productos_servicio_path(@producto_servicio), notice: "Producto o servicio creado correctamente."
    else
      preparar_precios_formulario
      preparar_costos_formulario
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :productos_servicios
    preparar_precios_formulario
    preparar_costos_formulario
  end

  def update
    @current_page = :productos_servicios

    if @producto_servicio.update(producto_servicio_params)
      redirect_to productos_servicio_path(@producto_servicio), notice: "Producto o servicio actualizado correctamente."
    else
      preparar_precios_formulario
      preparar_costos_formulario
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @producto_servicio.destroy
    redirect_to productos_servicios_path, notice: "Producto o servicio eliminado correctamente."
  end

  private

  def set_producto_servicio
    @producto_servicio = ProductoServicio.find(params[:id])
  end

  def cargar_catalogos
    @monedas = Moneda.activas.order(:codigo, :nombre)
    @companies = Company.order(:commercial_name, :legal_name)
    @clientes = Cliente.activos.ordenados
  end

  def cargar_cotizaciones
    @cotizaciones = @producto_servicio.cotizaciones.recientes
    @cotizacion_seleccionada = cotizacion_seleccionada
  end

  def cargar_cotizaciones_realizadas
    @cotizaciones_realizadas = @producto_servicio.cotizaciones
                                              .includes(:cliente_registro, cotizacion_detalles: :moneda)
                                              .recientes
  end

  def cotizacion_seleccionada
    @cotizacion_seleccionada ||= begin
      if params[:cotizacion_id].present?
        @producto_servicio.cotizaciones.find_by(id: params[:cotizacion_id])
      else
        @cotizaciones&.first
      end
    end
  end

  def modo_edicion_cotizacion?
    params[:modo] == "editar" && @cotizacion_seleccionada.present? && !@cotizacion_seleccionada.firmada?
  end

  def construir_cotizacion_base
    cotizacion = @producto_servicio.cotizaciones.build(
      cliente_id: nil,
      cliente: "",
      contacto: "",
      correo: "",
      telefono: "",
      vigencia_dias: 15,
      estado: "borrador",
      precio_base: @producto_servicio.precio_base,
      porcentaje_descuento: @producto_servicio.permite_descuento? ? @producto_servicio.porcentaje_descuento_maximo : nil,
      alcance_personalizado: "",
      observaciones: ""
    )
    preparar_detalles_cotizacion(cotizacion)
    cotizacion
  end

  def preparar_costos_formulario
    costos_visibles = @producto_servicio.producto_servicio_costos.reject(&:marked_for_destruction?)
    return if costos_visibles.any?

    @producto_servicio.producto_servicio_costos.build(
      activo: true,
      recurrencia: "Unico",
      orden: 0
    )
  end

  def preparar_precios_formulario
    precios_visibles = @producto_servicio.producto_servicio_precios.reject(&:marked_for_destruction?)
    return if precios_visibles.any?

    @producto_servicio.producto_servicio_precios.build(
      activo: true,
      cotizable: true,
      facturable: true,
      orden: 0,
      moneda_id: @producto_servicio.moneda_id,
      recurrencia: @producto_servicio.es_recurrente? ? (@producto_servicio.recurrencia.presence || "Mensual") : "Unico",
      seccion_cotizacion: @producto_servicio.es_recurrente? ? "Cargo mensual" : "Cargo inicial"
    )
  end

  def preparar_detalles_cotizacion(cotizacion, con_valores_base: true)
    detalles_visibles = cotizacion.cotizacion_detalles.reject(&:marked_for_destruction?)
    return if detalles_visibles.any?

    precios_base = @producto_servicio.producto_servicio_precios.activos.cotizables

    if precios_base.any?
      precios_base.each_with_index do |precio, index|
        cotizacion.cotizacion_detalles.build(
          producto_servicio_precio: precio,
          descripcion: [precio.nombre, precio.descripcion.presence].compact.join(" · "),
          catalog_price: precio.precio,
          applied_price: con_valores_base ? precio.precio : nil,
          internal_cost: @producto_servicio.costo_base,
          precio: con_valores_base ? precio.precio : 0,
          orden: index,
          moneda_id: precio.moneda_id || @producto_servicio.moneda_id,
          recurrencia: precio.recurrencia,
          seccion_cotizacion: precio.seccion_cotizacion,
          facturable: precio.facturable
        )
      end
      return
    end

    atributos = {
      catalog_price: @producto_servicio.precio_base,
      applied_price: con_valores_base ? @producto_servicio.precio_base : nil,
      internal_cost: @producto_servicio.costo_base,
      orden: 0,
      moneda_id: @producto_servicio.moneda_id,
      recurrencia: @producto_servicio.es_recurrente? ? (@producto_servicio.recurrencia.presence || "Mensual") : "Unico",
      seccion_cotizacion: @producto_servicio.es_recurrente? ? "Cargo mensual" : "Cargo inicial",
      facturable: @producto_servicio.facturable?
    }
    if con_valores_base
      atributos[:descripcion] = @producto_servicio.nombre
      atributos[:precio] = @producto_servicio.precio_base
    end

    cotizacion.cotizacion_detalles.build(atributos)
  end

  def preparar_formularios_show
    @tab_activa = params[:tab].presence || @tab_activa.presence || "general"
    @nuevo_precio ||= ProductoServicioPrecio.new(
      producto_servicio: @producto_servicio,
      activo: true,
      cotizable: true,
      facturable: true,
      orden: @producto_servicio.producto_servicio_precios.size,
      moneda_id: @producto_servicio.moneda_id,
      recurrencia: @producto_servicio.es_recurrente? ? (@producto_servicio.recurrencia.presence || "Mensual") : "Unico",
      seccion_cotizacion: @producto_servicio.es_recurrente? ? "Cargo mensual" : "Cargo inicial"
    )
    @nuevo_costo ||= ProductoServicioCosto.new(
      producto_servicio: @producto_servicio,
      activo: true,
      moneda_id: @producto_servicio.moneda_id,
      recurrencia: "Unico",
      orden: @producto_servicio.producto_servicio_costos.size
    )
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

  def producto_servicio_params
    params.require(:producto_servicio).permit(
      :nombre,
      :nombre_corto,
      :descripcion,
      :problema_resuelve,
      :caso_uso,
      :incluye_cotizacion,
      :requisitos_cierre_venta,
      :activo,
      :fecha_inicio_vigencia,
      :fecha_fin_vigencia,
      :tipo_producto,
      :product_type,
      :categoria,
      :subcategoria,
      :modelo_cobro,
      :estado_catalogo,
      :company_id,
      :moneda_id,
      :precio_base,
      :permite_descuento,
      :allow_discount,
      :porcentaje_descuento_maximo,
      :requiere_aprobacion_comercial,
      :es_recurrente,
      :is_recurring_service,
      :recurrencia,
      :dia_cobro,
      :cobra_proporcional,
      :requiere_consumo,
      :unidad_cobro,
      :cantidad_minima,
      :cantidad_maxima,
      :facturable,
      :billable,
      :tipo_facturacion,
      :agrupable_en_factura,
      :requiere_descripcion_dinamica,
      :requiere_activacion,
      :requiere_soporte,
      :nivel_servicio,
      :permite_suspension,
      :requiere_contrato,
      :duracion_minima_meses,
      :permite_renovacion,
      :liquidable,
      :modelo_liquidacion,
      :porcentaje_liquidacion,
      :base_liquidacion,
      :contabilizable,
      :cuenta_ingreso_codigo,
      :centro_costo_codigo,
      :visible_en_crm,
      :visible_en_contratos,
      :visible_en_expedientes,
      :visible_in_quote,
      :orden_visual,
      :afecto_iva,
      :tipo_impuesto,
      :requiere_fel_detallado,
      :costo_base,
      :margen_objetivo,
      :permite_costo_variable,
      :is_development,
      :is_implementation,
      :is_license,
      :no_charge_for_copenet,
      producto_servicio_precios_attributes: [
        :id,
        :nombre,
        :descripcion,
        :precio,
        :margen,
        :moneda_id,
        :recurrencia,
        :seccion_cotizacion,
        :cotizable,
        :facturable,
        :orden,
        :activo,
        :_destroy
      ],
      producto_servicio_costos_attributes: [
        :id,
        :tipo_costo,
        :nombre,
        :descripcion,
        :monto,
        :moneda_id,
        :recurrencia,
        :orden,
        :activo,
        :_destroy
      ],
      documentos_comerciales: []
    )
  end

  def producto_servicio_precio_params
    params.require(:producto_servicio_precio).permit(
      :nombre,
      :descripcion,
      :precio,
      :margen,
      :moneda_id,
      :recurrencia,
      :seccion_cotizacion,
      :cotizable,
      :facturable,
      :orden,
      :activo
    )
  end

  def producto_servicio_costo_params
    params.require(:producto_servicio_costo).permit(
      :tipo_costo,
      :nombre,
      :descripcion,
      :monto,
      :moneda_id,
      :recurrencia,
      :orden,
      :activo
    )
  end

  def aplicar_filtros(scope)
    scope = scope.where(
      "codigo ILIKE :term OR nombre ILIKE :term OR nombre_corto ILIKE :term OR descripcion ILIKE :term",
      term: "%#{@filtros[:query]}%"
    ) if @filtros[:query].present?

    scope = scope.where(estado_catalogo: @filtros[:estado_catalogo]) if @filtros[:estado_catalogo].present?
    scope = scope.where(modelo_cobro: @filtros[:modelo_cobro]) if @filtros[:modelo_cobro].present?
    scope
  end
end
