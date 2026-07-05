class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_login
  before_action :set_navigation
  before_action :authorize_modulo!

  helper_method :current_usuario, :usuario_signed_in?, :puede?, :permiso_efectivo

  private

  def current_usuario
    @current_usuario ||= Usuario.find_by(id: session[:usuario_id]) if session[:usuario_id]
  end

  def usuario_signed_in?
    current_usuario.present?
  end

  def require_login
    return if usuario_signed_in?

    redirect_to login_path, alert: "Debes iniciar sesión para continuar."
  end

  def puede?(accion, modulo_codigo)
    return false unless usuario_signed_in?
    modulo_sistema = ModuloSistema.find_by(codigo: modulo_codigo)
    return false unless modulo_sistema

    permiso_efectivo(current_usuario, modulo_sistema, accion)
  end

  def permiso_efectivo(usuario, modulo_sistema, accion)
    return false if usuario.blank? || modulo_sistema.blank?
    return true if usuario.root?

    permiso_directo = usuario.permiso_directo_para(modulo_sistema)
    return permiso_directo.public_send("puede_#{accion}?") if permiso_directo

    usuario.permiso_base_por_rol(modulo_sistema, accion)
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
      when "dashboard" then "DASHBOARD"
      when "productos_servicios" then "PRODUCTOS_SERVICIOS"
      else nil
      end
    when "monedas"
      "MONEDAS"
    when "companies"
      "COMPANIAS"
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
    when "edit", "update"
      :editar
    when "destroy"
      :eliminar
    when "configuration", "permisos", "actualizar_permisos"
      :configurar
    else
      :ver
    end
  end

  def set_navigation
    return @navigation_items = [] unless usuario_signed_in?

    admin_children = []
    admin_children << { key: :companies, label: "Compañías", path: companies_path, icon: "building" } if current_usuario.root? || puede?(:ver, "COMPANIAS")
    admin_children << { key: :usuarios, label: "Usuarios", path: usuarios_path, icon: "users" } if current_usuario.root? || puede?(:ver, "USUARIOS")
    admin_children << { key: :roles, label: "Roles y Permisos", path: roles_path, icon: "shield" } if current_usuario.root? || puede?(:ver, "ROLES")
    admin_children << { key: :monedas, label: "Monedas", path: monedas_path, icon: "coins" } if current_usuario.root? || puede?(:ver, "MONEDAS")
    admin_children << { key: :modulos_sistema, label: "Módulos del Sistema", path: modulos_sistema_index_path, icon: "layers" } if current_usuario.root? || puede?(:ver, "MODULOS_SISTEMA")
    cobros_children = []
    cobros_children << { key: :productos_servicios, label: "Productos y Servicios", path: productos_servicios_path, icon: "box" } if current_usuario.root? || puede?(:ver, "PRODUCTOS_SERVICIOS")
    reportes_children = []
    reportes_children << { key: :reports, label: "Reportes", path: reports_path, icon: "report" } if current_usuario.root?
    configuracion_children = []
    configuracion_children << { key: :parametros, label: "Parámetros", path: parametros_path, icon: "settings" } if current_usuario.root?
    configuracion_children << { key: :auditoria, label: "Auditoría", path: auditoria_path, icon: "shield" } if current_usuario.root?

    @navigation_items = []
    @navigation_items << { key: :dashboard, label: "Dashboard", path: dashboard_path, icon: "dashboard" } if current_usuario.root? || puede?(:ver, "DASHBOARD")
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

    @navigation_items.concat(
      [
        { key: :accounts, label: "Cuentas", path: accounts_path, icon: "wallet" },
        { key: :costs, label: "Costos", path: costs_path, icon: "coins" },
        { key: :collections, label: "Cobros Operativos", path: collections_path, icon: "receipt" },
        { key: :invoices, label: "Facturación", path: invoices_path, icon: "invoice" },
        { key: :contracts, label: "Contratos", path: contracts_path, icon: "contract" }
      ]
    ) if current_usuario.root?
  end

  def ruta_segura_post_login
    return dashboard_path if puede?(:ver, "DASHBOARD")
    return companies_path if puede?(:ver, "COMPANIAS")
    return usuarios_path if puede?(:ver, "USUARIOS")
    return roles_path if puede?(:ver, "ROLES")
    return monedas_path if puede?(:ver, "MONEDAS")
    return modulos_sistema_index_path if puede?(:ver, "MODULOS_SISTEMA")
    return productos_servicios_path if puede?(:ver, "PRODUCTOS_SERVICIOS")

    login_path
  end
end
