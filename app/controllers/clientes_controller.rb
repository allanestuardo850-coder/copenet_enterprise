class ClientesController < ApplicationController
  before_action :set_cliente, only: %i[show edit update]

  def index
    @current_page = :clientes
    @filtros = {
      query: params[:query].to_s.strip,
      client_type: params[:client_type].to_s.strip,
      status: params[:status].to_s.strip
    }

    @clientes = Cliente.includes(:expediente_cliente).ordenados
    @clientes = @clientes.where("nombre ILIKE :term OR email ILIKE :term OR contacto_principal ILIKE :term", term: "%#{@filtros[:query]}%") if @filtros[:query].present?
    @clientes = @clientes.where(client_type: @filtros[:client_type]) if @filtros[:client_type].present?
    @clientes = @clientes.where(activo: @filtros[:status] == "activo") if @filtros[:status].in?(%w[activo inactivo])
    @clientes_total_count = @clientes.count
    @clientes_per_page = clientes_per_page
    @clientes_total_pages = [(@clientes_total_count.to_f / @clientes_per_page).ceil, 1].max
    @clientes_page = [[params[:page].to_i, 1].max, @clientes_total_pages].min
    @clientes = @clientes.offset((@clientes_page - 1) * @clientes_per_page).limit(@clientes_per_page)
  end

  def show
    @current_page = :clientes
  end

  def new
    @current_page = :clientes
    @cliente = Cliente.new(client_type: "no_socio", activo: true)
  end

  def create
    @current_page = :clientes
    @cliente = Cliente.new(cliente_params)

    if @cliente.save
      redirect_to cliente_path(@cliente), notice: "Cliente creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :clientes
  end

  def update
    @current_page = :clientes

    if @cliente.update(cliente_params)
      redirect_to cliente_path(@cliente), notice: "Cliente actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_cliente
    @cliente = Cliente.find(params[:id])
  end

  def cliente_params
    params.require(:cliente).permit(
      :nombre,
      :contacto_principal,
      :email,
      :telefono,
      :client_type,
      :is_copenet_client,
      :activo,
      :notas
    )
  end

  def clientes_per_page
    allowed = [10, 20, 50, 100]
    value = params[:per_page].to_i
    allowed.include?(value) ? value : 10
  end
end
