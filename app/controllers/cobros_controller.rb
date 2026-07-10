class CobrosController < ApplicationController
  before_action :set_cobro, only: %i[show edit update]
  before_action :load_catalogs, only: %i[new create edit update]

  def index
    @current_page = :cobros_operativos
    @filters = { query: params[:query].to_s.strip, status: params[:status].to_s.strip }
    @cobros = apply_filters(Cobro.includes(:cliente, :moneda).ordenados)
    paginate_cobros
  end

  def show
    @current_page = :cobros_operativos
  end

  def new
    @current_page = :cobros_operativos
    @cobro = Cobro.new(fecha_vencimiento: Date.current, estado: "en_gestion", activo: true)
  end

  def create
    @current_page = :cobros_operativos
    @cobro = Cobro.new(cobro_params)

    if @cobro.save
      redirect_to cobros_path, notice: "Cobro guardado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :cobros_operativos
  end

  def update
    @current_page = :cobros_operativos

    if @cobro.update(cobro_params)
      redirect_to cobros_path, notice: "Cobro actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_cobro
    @cobro = Cobro.find(params[:id])
  end

  def load_catalogs
    @clientes = Cliente.ordenados
    @monedas = Moneda.activas.order(:nombre)
  end

  def cobro_params
    params.require(:cobro).permit(:referencia, :cliente_id, :cliente_nombre, :gestor, :fecha_vencimiento, :fecha_pago, :monto, :moneda_id, :estado, :notas, :activo)
  end

  def apply_filters(scope)
    if @filters[:query].present?
      term = "%#{@filters[:query]}%"
      scope = scope.where("referencia ILIKE :term OR cliente_nombre ILIKE :term OR gestor ILIKE :term", term: term)
    end
    scope = scope.where(estado: @filters[:status]) if @filters[:status].present?
    scope
  end

  def paginate_cobros
    @cobros_total_count = @cobros.count
    @cobros_per_page = per_page
    @cobros_total_pages = [(@cobros_total_count.to_f / @cobros_per_page).ceil, 1].max
    @cobros_page = [[params[:page].to_i, 1].max, @cobros_total_pages].min
    @cobros = @cobros.offset((@cobros_page - 1) * @cobros_per_page).limit(@cobros_per_page)
  end

  def per_page
    allowed = [10, 20, 50, 100]
    value = params[:per_page].to_i
    allowed.include?(value) ? value : 10
  end
end
