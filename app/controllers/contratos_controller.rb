class ContratosController < ApplicationController
  before_action :set_contrato, only: %i[show edit update]
  before_action :load_catalogs, only: %i[new create edit update]

  def index
    @current_page = :contratos
    @filters = { query: params[:query].to_s.strip, status: params[:status].to_s.strip }
    @contratos = apply_filters(Contrato.includes(:cliente, :moneda).ordenados)
    paginate_contratos
  end

  def show
    @current_page = :contratos
  end

  def new
    @current_page = :contratos
    @contrato = Contrato.new(fecha_inicio: Date.current, estado: "borrador", activo: true)
  end

  def create
    @current_page = :contratos
    @contrato = Contrato.new(contrato_params)

    if @contrato.save
      redirect_to contratos_path, notice: "Contrato guardado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :contratos
  end

  def update
    @current_page = :contratos

    if @contrato.update(contrato_params)
      redirect_to contratos_path, notice: "Contrato actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_contrato
    @contrato = Contrato.find(params[:id])
  end

  def load_catalogs
    @clientes = Cliente.ordenados
    @monedas = Moneda.activas.order(:nombre)
  end

  def contrato_params
    params.require(:contrato).permit(:codigo, :cliente_id, :cliente_nombre, :tipo_contrato, :fecha_inicio, :fecha_fin, :valor, :moneda_id, :estado, :responsable, :notas, :activo)
  end

  def apply_filters(scope)
    if @filters[:query].present?
      term = "%#{@filters[:query]}%"
      scope = scope.where("codigo ILIKE :term OR cliente_nombre ILIKE :term OR tipo_contrato ILIKE :term OR responsable ILIKE :term", term: term)
    end
    scope = scope.where(estado: @filters[:status]) if @filters[:status].present?
    scope
  end

  def paginate_contratos
    @contratos_total_count = @contratos.count
    @contratos_per_page = per_page
    @contratos_total_pages = [(@contratos_total_count.to_f / @contratos_per_page).ceil, 1].max
    @contratos_page = [[params[:page].to_i, 1].max, @contratos_total_pages].min
    @contratos = @contratos.offset((@contratos_page - 1) * @contratos_per_page).limit(@contratos_per_page)
  end

  def per_page
    allowed = [10, 20, 50, 100]
    value = params[:per_page].to_i
    allowed.include?(value) ? value : 10
  end
end
