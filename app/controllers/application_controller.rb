class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_login
  before_action :set_navigation
  before_action :authorize_modulo!

  helper_method :current_usuario, :usuario_signed_in?, :puede?

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
    return true if current_usuario.root?

    permiso = current_usuario.permisos_activos.find_by(modulo_sistemas: { codigo: modulo_codigo })
    return false unless permiso

    case accion.to_sym
    when :ver then permiso.puede_ver?
    when :crear then permiso.puede_crear?
    when :editar then permiso.puede_editar?
    when :eliminar then permiso.puede_eliminar?
    when :exportar then permiso.puede_exportar?
    when :configurar then permiso.puede_configurar?
    else
      false
    end
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
      action_name == "dashboard" ? "DASHBOARD" : nil
    when "companies"
      "COMPANIAS"
    when "usuarios"
      "USUARIOS"
    when "roles"
      "ROLES"
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

    @navigation_items = []
    @navigation_items << { key: :dashboard, label: "Dashboard", path: dashboard_path, icon: "dashboard" } if current_usuario.root? || puede?(:ver, "DASHBOARD")
    @navigation_items << {
      key: :administracion,
      label: "Administración",
      icon: "settings",
      children: admin_children
    } if admin_children.any?

    @navigation_items.concat(
      [
        { key: :accounts, label: "Cuentas", path: accounts_path, icon: "wallet" },
        { key: :services, label: "Servicios / Productos", path: services_path, icon: "box" },
        { key: :costs, label: "Costos", path: costs_path, icon: "coins" },
        { key: :collections, label: "Cobros", path: collections_path, icon: "receipt" },
        { key: :invoices, label: "Facturación", path: invoices_path, icon: "invoice" },
        { key: :contracts, label: "Contratos", path: contracts_path, icon: "contract" },
        { key: :reports, label: "Reportes", path: reports_path, icon: "report" },
        { key: :settings, label: "Configuración", path: settings_path, icon: "settings" }
      ]
    ) if current_usuario.root?
  end

  def ruta_segura_post_login
    return dashboard_path if puede?(:ver, "DASHBOARD")
    return companies_path if puede?(:ver, "COMPANIAS")
    return usuarios_path if puede?(:ver, "USUARIOS")
    return roles_path if puede?(:ver, "ROLES")

    login_path
  end
end
