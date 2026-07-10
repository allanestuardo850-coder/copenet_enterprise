class UsuariosController < ApplicationController
  before_action :set_usuario, only: %i[show edit update]

  def index
    @current_page = :usuarios
    @filters = {
      query: params[:query].to_s.strip,
      status: params[:status].to_s.strip,
      root: params[:root].to_s.strip
    }

    @usuarios = Usuario.includes(:roles).order(:nombre, :apellido)
    @usuarios = aplicar_filtros_usuarios(@usuarios)
    @usuarios_total_count = @usuarios.count
    @usuarios_per_page = usuarios_per_page
    @usuarios_total_pages = [(@usuarios_total_count.to_f / @usuarios_per_page).ceil, 1].max
    @usuarios_page = [[params[:page].to_i, 1].max, @usuarios_total_pages].min
    @usuarios = @usuarios.offset((@usuarios_page - 1) * @usuarios_per_page).limit(@usuarios_per_page)
  end

  def show
    @current_page = :usuarios
    cargar_permisos
  end

  def new
    @current_page = :usuarios
    @usuario = Usuario.new(activo: true, root: false)
    cargar_roles
  end

  def create
    @current_page = :usuarios
    @usuario = Usuario.new(usuario_params)
    cargar_roles

    if @usuario.save
      sync_roles
      redirect_to usuarios_path, notice: "Usuario creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :usuarios
    cargar_roles
    cargar_permisos
  end

  def update
    @current_page = :usuarios
    cargar_roles

    if @usuario.update(usuario_update_params)
      Usuario.transaction do
        role_changed = sync_roles
        sync_permisos_usuario(role_changed: role_changed)
      end
      redirect_to usuarios_path, notice: "Usuario actualizado correctamente."
    else
      cargar_permisos
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  def cargar_roles
    @roles = Rol.order(:nombre)
  end

  def cargar_permisos
    @modulo_sistemas = ModuloSistema.activos.orden_admin
    @modulo_sistemas_por_grupo = @modulo_sistemas.group_by { |modulo| modulo.grupo.presence || "Sin grupo" }
    @actividad_reciente = [
      {
        titulo: "Usuario actualizado",
        detalle: "Se sincronizaron roles y datos de acceso del perfil.",
        fecha: "Hoy, 08:45",
        tone: "primary"
      },
      {
        titulo: "Permisos personalizados guardados",
        detalle: "El usuario ya puede tener permisos propios además de los heredados por rol.",
        fecha: "Ayer, 16:20",
        tone: "success"
      },
      {
        titulo: "Módulos sincronizados",
        detalle: "Todo módulo activo aparece aquí automáticamente para que puedas configurarlo desde usuarios.",
        fecha: "Siempre",
        tone: "info"
      }
    ]
  end

  def sync_roles
    previous_role_ids = @usuario.rol_ids.map(&:to_s)
    rol_id = params.dig(:usuario, :rol_id).presence
    next_role_ids = rol_id.present? ? [rol_id.to_s] : []
    @usuario.rol_ids = next_role_ids
    previous_role_ids.sort != next_role_ids.sort
  end

  def sync_permisos_usuario(role_changed: false)
    if @usuario.root?
      @usuario.usuario_permisos.destroy_all
      return
    end

    dirty_ids = params.fetch(:usuario_permisos_dirty, []).map(&:to_s)
    @usuario.usuario_permisos.destroy_all if role_changed

    dirty_ids.each do |submitted_modulo_id|
      modulo = ModuloSistema.activos.find(submitted_modulo_id)
      values = permiso_usuario_params_for(modulo.id)
      actualizar_permiso_usuario_para(@usuario, modulo, values)
    end
  end

  def permiso_usuario_params_for(modulo_id)
    raw_values = params.fetch(:usuario_permisos, {}).fetch(modulo_id.to_s, {})
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

  def actualizar_permiso_usuario_para(usuario, modulo, values)
    permiso = usuario.usuario_permisos.find_or_initialize_by(modulo_sistema: modulo)
    permiso.assign_attributes(
      puede_ver: values["puede_ver"] == "1",
      puede_crear: values["puede_crear"] == "1",
      puede_editar: values["puede_editar"] == "1",
      puede_eliminar: values["puede_eliminar"] == "1",
      puede_exportar: values["puede_exportar"] == "1",
      puede_configurar: values["puede_configurar"] == "1"
    )
    permiso.save!
    permiso
  end

  def usuario_params
    params.require(:usuario).permit(
      :nombre, :apellido, :email, :password, :password_confirmation, :activo, :root
    )
  end

  def usuario_update_params
    permitted = usuario_params
    if permitted[:password].blank? && permitted[:password_confirmation].blank?
      permitted.except(:password, :password_confirmation)
    else
      permitted
    end
  end

  def aplicar_filtros_usuarios(scope)
    if @filters[:query].present?
      termino = "%#{@filters[:query]}%"
      scope = scope.where("nombre ILIKE :term OR apellido ILIKE :term OR email ILIKE :term", term: termino)
    end

    scope = scope.where(activo: @filters[:status] == "activo") if @filters[:status].in?(%w[activo inactivo])
    scope = scope.where(root: @filters[:root] == "si") if @filters[:root].in?(%w[si no])
    scope
  end

  def usuarios_per_page
    allowed = [10, 20, 50, 100]
    value = params[:per_page].to_i
    allowed.include?(value) ? value : 10
  end
end
