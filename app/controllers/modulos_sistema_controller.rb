class ModulosSistemaController < ApplicationController
  before_action :set_modulo_sistema, only: %i[show edit update destroy]

  def index
    @current_page = :modulos_sistema
    @modulos_sistema = ModuloSistema.orden_admin
  end

  def show
    @current_page = :modulos_sistema
  end

  def new
    @current_page = :modulos_sistema
    @modulo_sistema = ModuloSistema.new(activo: true, grupo: "Administración")
  end

  def create
    @current_page = :modulos_sistema
    @modulo_sistema = ModuloSistema.new(modulo_sistema_params)

    if @modulo_sistema.save
      redirect_to @modulo_sistema, notice: "Módulo del sistema creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :modulos_sistema
  end

  def update
    @current_page = :modulos_sistema

    if @modulo_sistema.update(modulo_sistema_params)
      redirect_to @modulo_sistema, notice: "Módulo del sistema actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @modulo_sistema.permisos.exists?
      redirect_to modulos_sistema_index_path, alert: "No puedes eliminar un módulo con permisos asociados."
      return
    end

    @modulo_sistema.destroy
    redirect_to modulos_sistema_index_path, notice: "Módulo del sistema eliminado correctamente."
  end

  private

  def set_modulo_sistema
    @modulo_sistema = ModuloSistema.find(params[:id])
  end

  def modulo_sistema_params
    params.require(:modulo_sistema).permit(:codigo, :nombre, :descripcion, :ruta, :grupo, :activo)
  end
end
