class RolesController < ApplicationController
  before_action :set_rol, only: %i[show edit update destroy permisos]

  def index
    @current_page = :roles
    @filters = {
      query: params[:query].to_s.strip,
      status: params[:status].to_s.strip
    }
    @roles = Rol.includes(:usuarios).order(:nombre)
    @roles = aplicar_filtros_roles(@roles)
    @roles_total_count = @roles.count
    @roles_per_page = roles_per_page
    @roles_total_pages = [(@roles_total_count.to_f / @roles_per_page).ceil, 1].max
    @roles_page = [[params[:page].to_i, 1].max, @roles_total_pages].min
    @roles = @roles.offset((@roles_page - 1) * @roles_per_page).limit(@roles_per_page)
  end

  def show
    @current_page = :roles
    cargar_permisos
  end

  def new
    @current_page = :roles
    @rol = Rol.new(activo: true)
  end

  def create
    @current_page = :roles
    @rol = Rol.new(rol_params)

    if @rol.save
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

    # En edición solo se actualiza la información del rol; los permisos se
    # asignan desde la vista de detalle (ver) del rol.
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
    cargar_permisos

    return unless request.patch?

    sync_permisos_rol

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to rol_path(@rol), notice: "Permisos actualizados correctamente." }
    end
  end

  private

  def set_rol
    @rol = Rol.find(params[:id])
  end

  def rol_params
    params.require(:rol).permit(:nombre, :descripcion, :activo)
  end

  def aplicar_filtros_roles(scope)
    if @filters[:query].present?
      termino = "%#{@filters[:query]}%"
      scope = scope.where("nombre ILIKE :term OR descripcion ILIKE :term", term: termino)
    end

    scope = scope.where(activo: @filters[:status] == "activo") if @filters[:status].in?(%w[activo inactivo])
    scope
  end

  def roles_per_page
    allowed = [10, 20, 50, 100]
    value = params[:per_page].to_i
    allowed.include?(value) ? value : 10
  end

  def cargar_permisos
    @modulo_sistemas = ModuloSistema.activos.orden_admin
    @modulo_sistemas_por_grupo = @modulo_sistemas.group_by { |modulo| modulo.grupo.presence || "Sin grupo" }
    @permisos_por_modulo = @rol.permisos.includes(:modulo_sistema).index_by(&:modulo_sistema_id)
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

  def guardar_rol_con_permisos
    saved = false
    Rol.transaction do
      saved = @rol.update(rol_params)
      raise ActiveRecord::Rollback unless saved

      sync_permisos_rol
    end
    saved
  rescue ActiveRecord::RecordInvalid
    false
  end

  def sync_permisos_rol
    ModuloSistema.activos.find_each do |modulo|
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
  end
end
