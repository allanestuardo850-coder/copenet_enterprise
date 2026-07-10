class MonedasController < ApplicationController
  before_action :set_moneda, only: %i[show edit update destroy]

  def index
    @current_page = :monedas
    @monedas = Moneda.order(:codigo, :nombre)
    @filters = {
      query: params[:query].to_s.strip,
      status: params[:status].to_s.strip
    }
    @monedas = apply_filters(@monedas)
    @monedas_total_count = @monedas.count
    @monedas_per_page = monedas_per_page
    @monedas_total_pages = [(@monedas_total_count.to_f / @monedas_per_page).ceil, 1].max
    @monedas_page = [[params[:page].to_i, 1].max, @monedas_total_pages].min
    @monedas = @monedas.offset((@monedas_page - 1) * @monedas_per_page).limit(@monedas_per_page)
  end

  def show
    @current_page = :monedas
  end

  def new
    @current_page = :monedas
    @moneda = Moneda.new(activo: true)
  end

  def create
    @current_page = :monedas
    @moneda = Moneda.new(moneda_params)

    if @moneda.save
      redirect_to @moneda, notice: "Moneda creada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :monedas
  end

  def update
    @current_page = :monedas

    if @moneda.update(moneda_params)
      redirect_to @moneda, notice: "Moneda actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @moneda.destroy
    redirect_to monedas_path, notice: "Moneda eliminada correctamente."
  end

  private

  def set_moneda
    @moneda = Moneda.find(params[:id])
  end

  def moneda_params
    params.require(:moneda).permit(:codigo, :nombre, :simbolo, :activo)
  end

  def apply_filters(scope)
    if @filters[:query].present?
      term = "%#{@filters[:query]}%"
      scope = scope.where("CAST(codigo AS TEXT) ILIKE :term OR nombre ILIKE :term OR simbolo ILIKE :term", term: term)
    end

    scope = scope.where(activo: @filters[:status] == "activo") if @filters[:status].in?(%w[activo inactivo])
    scope
  end

  def monedas_per_page
    allowed = [10, 20, 50, 100]
    value = params[:per_page].to_i
    allowed.include?(value) ? value : 10
  end
end
