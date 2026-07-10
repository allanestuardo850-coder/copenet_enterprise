class CostosController < ApplicationController
  before_action :set_costo, only: %i[show edit update]
  before_action :load_catalogs, only: %i[new create edit update]

  def index
    @current_page = :costos
    @filters = { query: params[:query].to_s.strip, status: params[:status].to_s.strip }
    @costos = apply_filters(Costo.includes(:moneda).ordenados)
    paginate_costos
  end

  def show
    @current_page = :costos
  end

  def new
    @current_page = :costos
    @costo = Costo.new(fecha: Date.current, estado: "registrado", activo: true)
  end

  def create
    @current_page = :costos
    @costo = Costo.new(costo_params)

    if @costo.save
      redirect_to costos_path, notice: "Costo guardado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :costos
  end

  def update
    @current_page = :costos

    if @costo.update(costo_params)
      redirect_to costos_path, notice: "Costo actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_costo
    @costo = Costo.find(params[:id])
  end

  def load_catalogs
    @monedas = Moneda.activas.order(:nombre)
  end

  def costo_params
    params.require(:costo).permit(:concepto, :centro_costo, :clasificacion, :periodo, :fecha, :monto, :moneda_id, :estado, :proveedor, :descripcion, :activo)
  end

  def apply_filters(scope)
    if @filters[:query].present?
      term = "%#{@filters[:query]}%"
      scope = scope.where("concepto ILIKE :term OR centro_costo ILIKE :term OR clasificacion ILIKE :term OR proveedor ILIKE :term", term: term)
    end
    scope = scope.where(estado: @filters[:status]) if @filters[:status].present?
    scope
  end

  def paginate_costos
    @costos_total_count = @costos.count
    @costos_per_page = per_page
    @costos_total_pages = [(@costos_total_count.to_f / @costos_per_page).ceil, 1].max
    @costos_page = [[params[:page].to_i, 1].max, @costos_total_pages].min
    @costos = @costos.offset((@costos_page - 1) * @costos_per_page).limit(@costos_per_page)
  end

  def per_page
    allowed = [10, 20, 50, 100]
    value = params[:per_page].to_i
    allowed.include?(value) ? value : 10
  end
end
