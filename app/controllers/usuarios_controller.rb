class UsuariosController < ApplicationController
  before_action :set_usuario, only: %i[show edit update permisos]

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
    cargar_actividad_usuario
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
      registrar_actividad_usuario!(
        "usuarios.created",
        "Usuario creado",
        subject: @usuario,
        metadata: { target_email: @usuario.email }
      )
      redirect_to usuarios_path, notice: "Usuario creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :usuarios
    cargar_roles
  end

  def update
    @current_page = :usuarios
    cargar_roles

    # En edición solo se actualiza la información propia del usuario y sus roles.
    # Los permisos por módulo se asignan desde la vista de detalle (ver).
    if @usuario.update(usuario_update_params)
      role_changed = sync_roles
      registrar_actividad_usuario!(
        "usuarios.updated",
        "Usuario actualizado",
        subject: @usuario,
        metadata: { target_email: @usuario.email }
      )
      if role_changed
        registrar_actividad_usuario!(
          "usuarios.roles_updated",
          "Roles del usuario actualizados",
          subject: @usuario,
          metadata: { target_email: @usuario.email, roles: @usuario.roles.pluck(:nombre) }
        )
      end
      redirect_to usuarios_path, notice: "Usuario actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def permisos
    @current_page = :usuarios
    changed_count = sync_permisos_usuario
    if changed_count.positive?
      registrar_actividad_usuario!(
        "usuarios.permissions_updated",
        "Permisos del usuario actualizados",
        subject: @usuario,
        metadata: { target_email: @usuario.email, modulos_actualizados: changed_count }
      )
    end

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to usuario_path(@usuario), notice: "Permisos actualizados correctamente." }
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
  end

  def cargar_actividad_usuario
    eventos = BitacoraEvento
              .where("usuario_id = :id OR (subject_type = 'Usuario' AND subject_id = :id)", id: @usuario.id)
              .recientes
              .limit(80)

    @actividad_items = eventos.map { |evento| item_actividad_usuario(evento) }
    agregar_actividad_creacion_fallback
  end

  def sync_roles
    previous_role_ids = @usuario.rol_ids.map(&:to_s)
    rol_id = params.dig(:usuario, :rol_id).presence
    next_role_ids = rol_id.present? ? [rol_id.to_s] : []
    @usuario.rol_ids = next_role_ids
    previous_role_ids.sort != next_role_ids.sort
  end

  def sync_permisos_usuario(role_changed: false)
    dirty_ids = params.fetch(:usuario_permisos_dirty, []).map(&:to_s)
    @usuario.usuario_permisos.destroy_all if role_changed

    changed_count = 0
    dirty_ids.each do |submitted_modulo_id|
      modulo = ModuloSistema.activos.find(submitted_modulo_id)
      values = permiso_usuario_params_for(modulo.id)
      actualizar_permiso_usuario_para(@usuario, modulo, values)
      changed_count += 1
    end
    changed_count
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

  def registrar_actividad_usuario!(event_type, description, subject:, metadata: {})
    BitacoraEvento.registrar!(
      event_type: event_type,
      description: description,
      subject: subject,
      usuario: current_usuario,
      metadata: {
        module_code: "USUARIOS",
        module_name: "Usuarios"
      }.merge(metadata)
    )
  end

  def codigo_modulo_evento(evento)
    metadata_code = evento.metadata["module_code"].presence
    return metadata_code if metadata_code.present?

    case evento.event_type.to_s.split(".").first
    when "acceso", "seguridad", "sesion" then "ACCESO"
    when "usuarios", "usuario" then "USUARIOS"
    when "roles", "permisos" then "ROLES"
    when "cliente", "clientes" then "CLIENTES"
    when "cotizacion", "cotizaciones" then "COTIZACIONES"
    when "producto", "productos" then "PRODUCTOS_SERVICIOS"
    else "ADMINISTRACION"
    end
  end

  def item_actividad_usuario(evento)
    {
      icon: icono_actividad_usuario(evento),
      module_name: nombre_modulo_evento(evento),
      label: evento.description,
      value: I18n.l(evento.created_at, format: :short),
      detail: detalle_actividad_usuario(evento)
    }
  end

  def nombre_modulo_evento(evento)
    evento.metadata["module_name"].presence ||
      ModuloSistema.find_by(codigo: codigo_modulo_evento(evento))&.nombre ||
      codigo_modulo_evento(evento).to_s.humanize
  end

  def icono_actividad_usuario(evento)
    case evento.event_type.to_s
    when /login|logout|sesion/ then "logout"
    when /created/ then "user-role"
    when /permission|permiso/ then "shield-outline"
    when /role|rol/ then "shield"
    else "report"
    end
  end

  def detalle_actividad_usuario(evento)
    actor = evento.usuario&.nombre_completo
    target = evento.subject.is_a?(Usuario) ? evento.subject.nombre_completo : nil
    return "Realizado por #{actor}" if actor.present? && target.blank?
    return "Afectó a #{target}" if target.present? && actor.blank?
    return "Realizado por #{actor} sobre #{target}" if actor.present? && target.present? && actor != target

    nil
  end

  def agregar_actividad_creacion_fallback
    @actividad_items ||= []
    return if @actividad_items.any? { |item| item[:label].to_s == "Usuario creado" }

    @actividad_items << {
      icon: "user-role",
      module_name: "Usuarios",
      label: "Usuario creado",
      value: I18n.l(@usuario.created_at, format: :short),
      detail: "Registro base del usuario"
    }
  end
end
