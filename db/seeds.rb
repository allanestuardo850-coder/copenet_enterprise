# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Company.find_or_initialize_by(tax_id: "103480861").tap do |company|
  company.commercial_name = "Copenet"
  company.legal_name = "Copenet, S.A."
  company.company_type = "Tecnología y Servicios"
  company.email = "info@copenet.com.gt"
  company.phone = "+502 2222-0000"
  company.address = "Ciudad de Guatemala, Guatemala"
  company.status = "Activa"
  company.active = true
  company.infile_prefix = "MCECSAPRO"
  company.infile_key = "65A948AB99814B245BD110CAB64E0FE7"
  company.infile_signature_prefix = "MCECSAPRO"
  company.infile_signature_key = "e8d3c14007fb41c9b927af7340dbe8a0"
  company.vat_affiliation = "GEN"
  company.fel_token = "cf99bd377f53f1116bf4c4fd15ebcb18"
  company.fel_scenario_code = "2"
  company.notification_email = "notificaciones@copenet.com.gt"
  company.save!
end

usuario_root = Usuario.find_or_initialize_by(email: "root@copenet.com.gt")
usuario_root.nombre = "Root"
usuario_root.apellido = "Sistema"
usuario_root.password = "Admin123!2026" if usuario_root.new_record?
usuario_root.password_confirmation = "Admin123!2026" if usuario_root.new_record?
usuario_root.activo = true
usuario_root.root = true
usuario_root.save!

rol_administrador = Rol.find_or_initialize_by(nombre: "Administrador")
rol_administrador.descripcion = "Rol administrador inicial del sistema."
rol_administrador.activo = true
rol_administrador.save!

UsuarioRol.find_or_create_by!(usuario: usuario_root, rol: rol_administrador)

[
  { codigo: "DASHBOARD", nombre: "Dashboard", descripcion: "Panel principal del sistema.", ruta: "/dashboard" },
  { codigo: "ADMINISTRACION", nombre: "Administración", descripcion: "Sección principal administrativa.", ruta: nil },
  { codigo: "COMPANIAS", nombre: "Compañías", descripcion: "Gestión de compañías.", ruta: "/companies" },
  { codigo: "USUARIOS", nombre: "Usuarios", descripcion: "Gestión de usuarios.", ruta: "/usuarios" },
  { codigo: "ROLES", nombre: "Roles y Permisos", descripcion: "Gestión de roles y permisos.", ruta: "/roles" }
].each do |attrs|
  modulo = ModuloSistema.find_or_initialize_by(codigo: attrs[:codigo])
  modulo.assign_attributes(attrs.merge(activo: true))
  modulo.save!

  permiso = Permiso.find_or_initialize_by(rol: rol_administrador, modulo_sistema: modulo)
  permiso.assign_attributes(
    puede_ver: true,
    puede_crear: true,
    puede_editar: true,
    puede_eliminar: true,
    puede_exportar: true,
    puede_configurar: true
  )
  permiso.save!
end
