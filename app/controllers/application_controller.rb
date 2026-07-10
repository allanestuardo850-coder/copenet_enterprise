class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_login
  before_action :set_navigation
  before_action :authorize_modulo!

  helper_method :current_usuario, :usuario_signed_in?, :puede?, :permiso_efectivo

  around_action :set_current_attributes

  private

  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id]) if session[:usuario_id]
  end

  def usuario_signed_in?
    current_usuario.present?
  end

  def require_login
    return if usuario_signed_in?

    redirect_to login_path
  end

  def puede?(accion, modulo_codigo)
    return false unless usuario_signed_in?
    return true if current_usuario.root?

    modulo_sistema = modulo_sistema_por_codigo[modulo_codigo.to_s]
    return false unless modulo_sistema

    permiso_efectivo(current_usuario, modulo_sistema, accion)
  end

  def permiso_efectivo(usuario, modulo_sistema, accion)
    return false if usuario.blank? || modulo_sistema.blank?
    return true if usuario.root?
    precargar_permisos_usuario(usuario)

    cache_key = [usuario.id, modulo_sistema.id, accion.to_sym]
    @permiso_efectivo_cache ||= {}
    return @permiso_efectivo_cache[cache_key] if @permiso_efectivo_cache.key?(cache_key)

    permiso_directo = permiso_directo_precargado(usuario, modulo_sistema)
    return permiso_habilitado?(permiso_directo, accion) if permiso_directo

    @permiso_efectivo_cache[cache_key] = permiso_base_por_rol_precargado(usuario, modulo_sistema, accion)
  end

  def permiso_habilitado?(permiso, accion)
    case accion.to_sym
    when :ver
      permiso.puede_ver?
    when :crear
      permiso.puede_crear?
    when :editar
      permiso.puede_editar?
    when :eliminar
      permiso.puede_eliminar?
    when :exportar
      permiso.puede_exportar?
    when :configurar
      permiso.puede_configurar?
    else
      false
    end
  end

  def modulo_sistema_por_codigo
    @modulo_sistema_por_codigo ||= ModuloSistema.activos.index_by(&:codigo)
  end

  def precargar_permisos_usuario(usuario)
    return if @permisos_usuario_precargados

    ActiveRecord::Associations::Preloader.new(
      records: [usuario],
      associations: [:usuario_permisos, { roles: { permisos: :modulo_sistema } }]
    ).call
    @permisos_usuario_precargados = true
  end

  def permiso_directo_precargado(usuario, modulo_sistema)
    if usuario.usuario_permisos.loaded?
      usuario.usuario_permisos.detect { |permiso| permiso.modulo_sistema_id == modulo_sistema.id }
    else
      usuario.permiso_directo_para(modulo_sistema)
    end
  end

  def permiso_base_por_rol_precargado(usuario, modulo_sistema, accion)
    permisos = if usuario.roles.loaded?
                 usuario.roles.select(&:activo?).flat_map do |rol|
                   rol.permisos.loaded? ? rol.permisos : rol.permisos.includes(:modulo_sistema)
                 end
               else
                 usuario.permisos_activos
               end

    permiso = permisos.find do |permiso_rol|
      permiso_rol.modulo_sistema_id == modulo_sistema.id &&
        (!permiso_rol.association(:modulo_sistema).loaded? || permiso_rol.modulo_sistema.activo?)
    end

    permiso.present? && permiso_habilitado?(permiso, accion)
  end

  def authorize_modulo!
    return unless usuario_signed_in?
    return if current_usuario.root?

    modulo_codigo = modulo_codigo_actual
    if modulo_codigo.blank?
      redirect_to ruta_segura_post_login, alert: "No tienes permisos para acceder a esta sección."
      return
    end
    return if puede?(accion_permiso_actual, modulo_codigo)

    redirect_to ruta_segura_post_login, alert: "No tienes permisos para acceder a esta sección."
  end

  def modulo_codigo_actual
    case controller_name
    when "enterprise"
      case action_name
      when "dashboard", "dashboard_finance" then "DASHBOARD"
      else nil
      end
    when "monedas"
      "MONEDAS"
    when "clientes"
      "CLIENTES"
    when "expediente_clientes"
      "EXPEDIENTES_CLIENTES"
    when "companies"
      "COMPANIAS"
    when "productos_servicios"
      "PRODUCTOS_SERVICIOS"
    when "cotizaciones"
      "COTIZACIONES"
    when "costos"
      "COSTOS"
    when "cobros"
      "COBROS"
    when "facturas"
      "FACTURAS"
    when "contratos"
      "CONTRATOS"
    when "usuarios"
      "USUARIOS"
    when "roles"
      "ROLES"
    when "modulos_sistema"
      "MODULOS_SISTEMA"
    else
      nil
    end
  end

  def accion_permiso_actual
    case action_name
    when "index", "show", "dashboard"
      :ver
    when "new", "create"
      :crear
    when "edit", "update", "agregar_precio", "agregar_costo"
      :editar
    when "destroy"
      :eliminar
    when "configuration", "permisos", "actualizar_permisos", "actualizar_parametros"
      :configurar
    else
      :ver
    end
  end

  def set_navigation
    return @navigation_items = [] unless usuario_signed_in?

    admin_children = navigation_items_for(
      [
        [:companies, "Compañías", companies_path, "building", "COMPANIAS"],
        [:usuarios, "Usuarios", usuarios_path, "users", "USUARIOS"],
        [:roles, "Roles y Permisos", roles_path, "shield", "ROLES"],
        [:monedas, "Monedas", monedas_path, "coins", "MONEDAS"],
        [:modulos_sistema, "Módulos del Sistema", modulos_sistema_index_path, "layers", "MODULOS_SISTEMA"]
      ]
    )
    cobros_children = navigation_items_for(
      [
        [:clientes, "Clientes", clientes_path, "users", "CLIENTES"],
        [:productos_servicios, "Productos y Servicios", productos_servicios_path, "box", "PRODUCTOS_SERVICIOS"],
        [:cotizaciones, "Cotizaciones", cotizaciones_path, "report", "COTIZACIONES"],
        [:costos, "Costos", costos_path, "coins", "COSTOS"],
        [:cobros_operativos, "Cobros", cobros_path, "receipt", "COBROS"],
        [:facturas, "Facturación", facturas_path, "invoice", "FACTURAS"],
        [:contratos, "Contratos", contratos_path, "contract", "CONTRATOS"]
      ]
    )
    reportes_children = []
    reportes_children << { key: :reports, label: "Reportes", path: reports_path, icon: "report" } if current_usuario.root?
    configuracion_children = []
    if current_usuario.root?
      configuracion_children << { key: :parametros, label: "Parámetros", path: parametros_path, icon: "settings" }
      configuracion_children << { key: :auditoria, label: "Auditoría", path: auditoria_path, icon: "shield" }
    end

    @navigation_items = []
    if current_usuario.root? || puede?(:ver, "DASHBOARD")
      @navigation_items << { key: :dashboard, label: "Dashboard", path: dashboard_path, icon: "dashboard" }
    end
    @navigation_items << {
      key: :administracion,
      label: "Administración",
      icon: "settings",
      children: admin_children
    } if admin_children.any?
    @navigation_items << {
      key: :cobros,
      label: "Cobros",
      icon: "receipt",
      children: cobros_children
    } if cobros_children.any?
    @navigation_items << {
      key: :reportes,
      label: "Reportes",
      icon: "report",
      children: reportes_children
    } if reportes_children.any?
    @navigation_items << {
      key: :configuracion,
      label: "Configuración",
      icon: "settings",
      children: configuracion_children
    } if configuracion_children.any?

    @navigation_items << { key: :accounts, label: "Cuentas", path: accounts_path, icon: "wallet" } if current_usuario.root?
  end

  def navigation_items_for(items)
    items.filter_map do |key, label, path, icon_name, modulo_codigo|
      next unless current_usuario.root? || puede?(:ver, modulo_codigo)

      { key: key, label: label, path: path, icon: icon_name }
    end
  end

  def ruta_segura_post_login
    return dashboard_path if current_usuario&.root?
    return dashboard_path if puede?(:ver, "DASHBOARD")
    return companies_path if puede?(:ver, "COMPANIAS")
    return clientes_path if defined?(clientes_path) && puede?(:ver, "CLIENTES")
    return usuarios_path if puede?(:ver, "USUARIOS")
    return roles_path if puede?(:ver, "ROLES")
    return monedas_path if puede?(:ver, "MONEDAS")
    return modulos_sistema_index_path if puede?(:ver, "MODULOS_SISTEMA")
    return productos_servicios_path if puede?(:ver, "PRODUCTOS_SERVICIOS")
    return cotizaciones_path if puede?(:ver, "COTIZACIONES")
    return costos_path if puede?(:ver, "COSTOS")
    return cobros_path if puede?(:ver, "COBROS")
    return facturas_path if puede?(:ver, "FACTURAS")
    return contratos_path if puede?(:ver, "CONTRATOS")

    login_path
  end

  def set_current_attributes
    Current.usuario = current_usuario
    yield
  ensure
    Current.reset
  end
end
