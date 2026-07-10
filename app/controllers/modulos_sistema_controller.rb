class ModulosSistemaController < ApplicationController
  before_action :set_modulo_sistema, only: %i[show edit update destroy]

  def index
    @current_page = :modulos_sistema
    @modulos_sistema = ModuloSistema.orden_admin
    @filters = {
      query: params[:query].to_s.strip,
      status: params[:status].to_s.strip
    }
    @modulos_sistema = apply_filters(@modulos_sistema)
    @modulos_sistema_total_count = @modulos_sistema.count
    @modulos_sistema_per_page = modulos_sistema_per_page
    @modulos_sistema_total_pages = [(@modulos_sistema_total_count.to_f / @modulos_sistema_per_page).ceil, 1].max
    @modulos_sistema_page = [[params[:page].to_i, 1].max, @modulos_sistema_total_pages].min
    @modulos_sistema = @modulos_sistema.offset((@modulos_sistema_page - 1) * @modulos_sistema_per_page).limit(@modulos_sistema_per_page)
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

  def apply_filters(scope)
    if @filters[:query].present?
      term = "%#{@filters[:query]}%"
      scope = scope.where("codigo ILIKE :term OR nombre ILIKE :term OR descripcion ILIKE :term OR ruta ILIKE :term OR grupo ILIKE :term", term: term)
    end

    scope = scope.where(activo: @filters[:status] == "activo") if @filters[:status].in?(%w[activo inactivo])
    scope
  end

  def modulos_sistema_per_page
    allowed = [10, 20, 50, 100]
    value = params[:per_page].to_i
    allowed.include?(value) ? value : 10
  end
end
