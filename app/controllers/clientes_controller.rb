class ClientesController < ApplicationController
  before_action :set_cliente, only: %i[show edit update]

  def index
    @current_page = :clientes
    @filtros = {
      query: params[:query].to_s.strip,
      client_type: params[:client_type].to_s.strip
    }

    @clientes = Cliente.includes(:expediente_cliente).ordenados
    @clientes = @clientes.where("nombre ILIKE :term OR email ILIKE :term OR contacto_principal ILIKE :term", term: "%#{@filtros[:query]}%") if @filtros[:query].present?
    @clientes = @clientes.where(client_type: @filtros[:client_type]) if @filtros[:client_type].present?
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
end
