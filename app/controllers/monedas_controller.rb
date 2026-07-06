class MonedasController < ApplicationController
  before_action :set_moneda, only: %i[show edit update destroy]

  def index
    @current_page = :monedas
    @monedas = Moneda.order(:codigo, :nombre)
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
end
