class RolesController < ApplicationController
  before_action :set_rol, only: %i[show edit update destroy permisos]

  def index
    @current_page = :roles
    @roles = Rol.includes(:usuarios).order(:nombre)
  end

  def show
    @current_page = :roles
  end

  def new
    @current_page = :roles
    @rol = Rol.new(activo: true)
  end

  def create
    @current_page = :roles
    @rol = Rol.new(rol_params)

    if @rol.save
      crear_permisos_faltantes
      redirect_to @rol, notice: "Rol creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :roles
  end

  def update
    @current_page = :roles

    if @rol.update(rol_params)
      redirect_to @rol, notice: "Rol actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @rol.usuarios.exists?
      redirect_to roles_path, alert: "No puedes eliminar un rol asignado a usuarios."
      return
    end

    @rol.destroy
    redirect_to roles_path, notice: "Rol eliminado correctamente."
  end

  def permisos
    @current_page = :roles
    crear_permisos_faltantes
    @modulo_sistemas = ModuloSistema.order(:codigo)
    @permisos_por_modulo = @rol.permisos.includes(:modulo_sistema).index_by(&:modulo_sistema_id)

    return unless request.patch?

    ModuloSistema.find_each do |modulo|
      permiso = @rol.permisos.find_or_initialize_by(modulo_sistema: modulo)
      values = permiso_params_for(modulo.id)
      permiso.assign_attributes(
        puede_ver: values["puede_ver"] == "1",
        puede_crear: values["puede_crear"] == "1",
        puede_editar: values["puede_editar"] == "1",
        puede_eliminar: values["puede_eliminar"] == "1",
        puede_exportar: values["puede_exportar"] == "1",
        puede_configurar: values["puede_configurar"] == "1"
      )
      permiso.save!
    end

    redirect_to permisos_rol_path(@rol), notice: "Permisos actualizados correctamente."
  end

  private

  def set_rol
    @rol = Rol.find(params[:id])
  end

  def rol_params
    params.require(:rol).permit(:nombre, :descripcion, :activo)
  end

  def permiso_params_for(modulo_id)
    raw_values = params.fetch(:permisos, {}).fetch(modulo_id.to_s, {})
    return raw_values if raw_values.is_a?(Hash)

    raw_values.permit(
      :puede_ver,
      :puede_crear,
      :puede_editar,
      :puede_eliminar,
      :puede_exportar,
      :puede_configurar
    ).to_h
  end

  def crear_permisos_faltantes
    ModuloSistema.find_each do |modulo|
      @rol.permisos.find_or_create_by!(modulo_sistema: modulo)
    end
  end
end
