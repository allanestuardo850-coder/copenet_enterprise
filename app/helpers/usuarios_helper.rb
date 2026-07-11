module UsuariosHelper
  ACCIONES_PERMISO = %i[ver crear editar eliminar exportar configurar].freeze
  ETIQUETAS_ACCIONES_PERMISO = {
    ver: "Ver",
    crear: "Crear",
    editar: "Editar",
    eliminar: "Inhabilitar",
    exportar: "Exportar",
    configurar: "Configurar"
  }.freeze

  def permiso_accion_label(accion)
    ETIQUETAS_ACCIONES_PERMISO.fetch(accion.to_sym, accion.to_s.humanize)
  end

  def usuario_valor(value, fallback = "Pendiente de configurar")
    value.presence || fallback
  end

  def usuario_fecha(value, fallback = "Sin registros")
    return fallback if value.blank?

    l(value, format: "%d/%m/%Y %H:%M")
  end

  def permiso_base_usuario(usuario, modulo_sistema, accion)
    usuario.permiso_base_por_rol(modulo_sistema, accion)
  end

  def permiso_personalizado_usuario(usuario, modulo_sistema, accion)
    permiso = usuario.permiso_directo_para(modulo_sistema)
    return nil unless permiso

    permiso.public_send("puede_#{accion}?")
  end
end
