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
  company.correo_comercial = "comercial@copenet.com.gt"
  company.phone = "+502 2222-0000"
  company.web = "https://copenet.com.gt"
  company.address = "Ciudad de Guatemala, Guatemala"
  company.status = "Activa"
  company.active = true
  company.color_primario = "#2458E6"
  company.color_secundario = "#0B2D66"
  company.color_acento = "#6EB8FF"
  company.infile_prefix = "MCECSAPRO"
  company.infile_key = "65A948AB99814B245BD110CAB64E0FE7"
  company.infile_signature_prefix = "MCECSAPRO"
  company.infile_signature_key = "e8d3c14007fb41c9b927af7340dbe8a0"
  company.vat_affiliation = "GEN"
  company.fel_token = "cf99bd377f53f1116bf4c4fd15ebcb18"
  company.fel_scenario_code = "2"
  company.notification_email = "notificaciones@copenet.com.gt"
  company.quote_format_name = "Propuesta Comercial Copenet"
  company.quote_contact_name = "Equipo Comercial Copenet"
  company.quote_contact_role = "Dirección Comercial"
  company.quote_contact_email = "comercial@copenet.com.gt"
  company.quote_contact_phone = "+502 2222-0000"
  company.quote_website_url = "https://copenet.com.gt"
  company.quote_table_header_color = "#DCEBFF"
  company.quote_contact_text_color = "#2458E6"
  company.quote_title = "Propuesta Comercial Copenet Enterprise"
  company.quote_subtitle = "Documento comercial y autorizable generado desde el catálogo maestro de soluciones."
  company.quote_intro_text = "Agradecemos el interés en nuestras soluciones. A continuación presentamos una propuesta estructurada para evaluación, autorización y posterior transición al flujo operativo y de facturación."
  company.quote_terms_text = "Los importes, alcances y tiempos aquí indicados están sujetos a validación comercial final, aprobación interna y formalización contractual según el tipo de servicio contratado."
  company.quote_closing_text = "Quedamos atentos para ampliar cualquier sección de esta propuesta, ajustar el alcance final y continuar con el proceso de activación comercial correspondiente."
  company.quote_signature_name = "Equipo Comercial Copenet"
  company.quote_signature_role = "Dirección Comercial"
  company.quote_footer_note = "Documento comercial emitido por Copenet, S.A. Todos los valores están sujetos a validación comercial y condiciones finales de contratación."
  company.save!
end

ConfiguracionSistema.first_or_initialize.tap do |configuracion|
  configuracion.assign_attributes(ConfiguracionSistema.default_attributes)
  configuracion.save!
end

company_base = Company.find_by(tax_id: "103480861")

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
  { codigo: "DASHBOARD", nombre: "Dashboard", descripcion: "Panel principal del sistema.", ruta: "/dashboard", grupo: "General" },
  { codigo: "ADMINISTRACION", nombre: "Administración", descripcion: "Sección principal administrativa.", ruta: nil, grupo: "Administración" },
  { codigo: "COMPANIAS", nombre: "Compañías", descripcion: "Gestión de compañías.", ruta: "/companies", grupo: "Administración" },
  { codigo: "USUARIOS", nombre: "Usuarios", descripcion: "Gestión de usuarios.", ruta: "/usuarios", grupo: "Administración" },
  { codigo: "ROLES", nombre: "Roles y Permisos", descripcion: "Gestión de roles y permisos.", ruta: "/roles", grupo: "Administración" },
  { codigo: "MONEDAS", nombre: "Monedas", descripcion: "Catálogo de monedas del sistema.", ruta: "/monedas", grupo: "Administración" },
  { codigo: "CLIENTES", nombre: "Clientes", descripcion: "Gestión de clientes tipificados para reglas CopeNET y expediente.", ruta: "/clientes", grupo: "Administración" },
  { codigo: "EXPEDIENTES_CLIENTES", nombre: "Expedientes de Cliente", descripcion: "Expediente operativo y comercial del cliente.", ruta: "/clientes/:id/expediente", grupo: "Administración" },
  { codigo: "MODULOS_SISTEMA", nombre: "Módulos del Sistema", descripcion: "Registro técnico de módulos para navegación y permisos.", ruta: "/modulos_sistema", grupo: "Administración" },
  { codigo: "PRODUCTOS_SERVICIOS", nombre: "Productos y Servicios", descripcion: "Catálogo de productos, servicios, licencias y cargos para cobros y facturación.", ruta: "/productos_servicios", grupo: "Cobros" },
  { codigo: "COTIZACIONES", nombre: "Cotizaciones", descripcion: "Listado central de cotizaciones generadas desde productos y servicios.", ruta: "/cotizaciones", grupo: "Cobros" },
  { codigo: "COSTOS", nombre: "Costos", descripcion: "Registro de costos operativos, centros de costo y proveedores.", ruta: "/costos", grupo: "Cobros" },
  { codigo: "COBROS", nombre: "Cobros", descripcion: "Seguimiento operativo de cobros, vencimientos y pagos recibidos.", ruta: "/cobros", grupo: "Cobros" },
  { codigo: "FACTURAS", nombre: "Facturación", descripcion: "Control de facturas emitidas, vencimientos y estados de pago.", ruta: "/facturas", grupo: "Cobros" },
  { codigo: "CONTRATOS", nombre: "Contratos", descripcion: "Gestión de contratos, vigencias, renovaciones y responsables.", ruta: "/contratos", grupo: "Cobros" }
].each do |attrs|
  modulo = if attrs[:codigo] == "PRODUCTOS_SERVICIOS"
             ModuloSistema.where(codigo: ["PRODUCTOS_SERVICIOS", "SERVICES", "PRODUCTOS", "SERVICIOS"]).or(
               ModuloSistema.where(ruta: ["/services", "/productos_servicios"])
             ).or(
               ModuloSistema.where(nombre: ["Servicios / Productos", "Productos y Servicios"])
             ).first_or_initialize
           else
             ModuloSistema.find_or_initialize_by(codigo: attrs[:codigo])
           end

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

[
  {
    nombre: "Cliente CopeNET Interno",
    contacto_principal: "María Pérez",
    email: "cliente.copenet@copenet.com.gt",
    telefono: "+502 5555-1000",
    client_type: "copenet",
    is_copenet_client: true,
    activo: true,
    notas: "Cliente interno para pruebas de reglas sin cobro."
  },
  {
    nombre: "Cliente No Socio Demo",
    contacto_principal: "Juan López",
    email: "cliente.nosocio@example.com",
    telefono: "+502 5555-2000",
    client_type: "no_socio",
    is_copenet_client: false,
    activo: true,
    notas: "Cliente externo para pruebas comerciales estándar."
  }
].each do |attrs|
  cliente = Cliente.find_or_initialize_by(email: attrs[:email])
  cliente.assign_attributes(attrs)
  cliente.save!
end

[
  { codigo: 320, nombre: "Quetzal", simbolo: "Q", activo: true },
  { codigo: 840, nombre: "Dólar estadounidense", simbolo: "$", activo: true },
  { codigo: 978, nombre: "Euro", simbolo: "EUR", activo: true }
].each do |attrs|
  moneda = Moneda.find_or_initialize_by(codigo: attrs[:codigo])
  moneda.assign_attributes(attrs)
  moneda.save!
end

moneda_base = Moneda.find_by(codigo: 320)

[
  {
    codigo: "PS-SAAS-001",
    nombre: "Licencia SaaS Enterprise",
    nombre_corto: "SaaS Enterprise",
    descripcion: "Suscripción recurrente para acceso a la plataforma empresarial con módulos administrativos y operativos.",
    activo: true,
    fecha_inicio_vigencia: Date.new(2026, 1, 1),
    tipo_producto: "Licencia",
    categoria: "Cobro recurrente",
    subcategoria: "SaaS",
    modelo_cobro: "Recurrente",
    estado_catalogo: "Aprobado",
    company: company_base,
    moneda: moneda_base,
    precio_base: 1499.00,
    permite_descuento: true,
    porcentaje_descuento_maximo: 15,
    requiere_aprobacion_comercial: false,
    es_recurrente: true,
    recurrencia: "Mensual",
    dia_cobro: 5,
    cobra_proporcional: true,
    requiere_consumo: false,
    facturable: true,
    tipo_facturacion: "Anticipada",
    agrupable_en_factura: true,
    requiere_descripcion_dinamica: false,
    requiere_activacion: true,
    requiere_soporte: true,
    nivel_servicio: "Premium",
    permite_suspension: true,
    requiere_contrato: true,
    duracion_minima_meses: 12,
    permite_renovacion: true,
    liquidable: false,
    contabilizable: true,
    cuenta_ingreso_codigo: "4101-01",
    centro_costo_codigo: "COB-SAAS",
    visible_en_crm: true,
    visible_en_contratos: true,
    visible_en_expedientes: true,
    orden_visual: 10,
    afecto_iva: true,
    tipo_impuesto: "IVA",
    requiere_fel_detallado: true,
    costo_base: 450.00,
    margen_objetivo: 35,
    permite_costo_variable: false
  },
  {
    codigo: "PS-TRX-002",
    nombre: "Procesamiento Transaccional",
    nombre_corto: "Procesamiento",
    descripcion: "Cargo variable por transacción procesada con liquidación y trazabilidad operativa.",
    activo: true,
    fecha_inicio_vigencia: Date.new(2026, 1, 1),
    tipo_producto: "Servicio transaccional",
    categoria: "Cobro transaccional",
    subcategoria: "Procesamiento",
    modelo_cobro: "Transaccional",
    estado_catalogo: "Aprobado",
    company: company_base,
    moneda: moneda_base,
    precio_base: 0.75,
    permite_descuento: false,
    requiere_aprobacion_comercial: true,
    es_recurrente: false,
    cobra_proporcional: false,
    requiere_consumo: true,
    unidad_cobro: "Transaccion",
    cantidad_minima: 1,
    facturable: true,
    tipo_facturacion: "Consolidada",
    agrupable_en_factura: true,
    requiere_descripcion_dinamica: true,
    requiere_activacion: true,
    requiere_soporte: true,
    nivel_servicio: "Critico",
    permite_suspension: false,
    requiere_contrato: true,
    permite_renovacion: true,
    liquidable: true,
    modelo_liquidacion: "Porcentaje",
    porcentaje_liquidacion: 12,
    base_liquidacion: "Cobrado",
    contabilizable: true,
    cuenta_ingreso_codigo: "4102-08",
    centro_costo_codigo: "COB-TRX",
    visible_en_crm: true,
    visible_en_contratos: true,
    visible_en_expedientes: true,
    orden_visual: 20,
    afecto_iva: true,
    tipo_impuesto: "IVA",
    requiere_fel_detallado: true,
    costo_base: 0.18,
    margen_objetivo: 28,
    permite_costo_variable: true
  },
  {
    codigo: "PS-IMP-003",
    nombre: "Implementación Inicial",
    nombre_corto: "Implementación",
    descripcion: "Cargo único para parametrización, acompañamiento y salida en producción.",
    activo: true,
    fecha_inicio_vigencia: Date.new(2026, 1, 1),
    tipo_producto: "Implementacion",
    categoria: "Cobro unico",
    subcategoria: "Onboarding",
    modelo_cobro: "Fijo",
    estado_catalogo: "Borrador",
    company: company_base,
    moneda: moneda_base,
    precio_base: 6500.00,
    permite_descuento: true,
    porcentaje_descuento_maximo: 10,
    requiere_aprobacion_comercial: true,
    es_recurrente: false,
    cobra_proporcional: false,
    requiere_consumo: false,
    facturable: true,
    tipo_facturacion: "Inmediata",
    agrupable_en_factura: false,
    requiere_descripcion_dinamica: false,
    requiere_activacion: true,
    requiere_soporte: false,
    nivel_servicio: "Estándar",
    permite_suspension: false,
    requiere_contrato: true,
    duracion_minima_meses: 0,
    permite_renovacion: false,
    liquidable: false,
    contabilizable: true,
    cuenta_ingreso_codigo: "4103-03",
    centro_costo_codigo: "COB-IMP",
    visible_en_crm: true,
    visible_en_contratos: true,
    visible_en_expedientes: true,
    orden_visual: 30,
    afecto_iva: true,
    tipo_impuesto: "IVA",
    requiere_fel_detallado: false,
    costo_base: 2400.00,
    margen_objetivo: 30,
    permite_costo_variable: true
  }
].each do |attrs|
  producto_servicio = ProductoServicio.find_or_initialize_by(codigo: attrs[:codigo])
  producto_servicio.assign_attributes(attrs)
  producto_servicio.save!
end

moneda_dolar = Moneda.find_by(codigo: 840)

producto_saas = ProductoServicio.find_by(codigo: "PS-SAAS-001")
if producto_saas
  [
    {
      nombre: "Licencia base SaaS",
      descripcion: "Uso mensual de la plataforma empresarial.",
      precio: 1499.00,
      margen: 35,
      moneda: moneda_base,
      recurrencia: "Mensual",
      seccion_cotizacion: "Cargo mensual",
      cotizable: true,
      facturable: true,
      orden: 0
    },
    {
      nombre: "Soporte premium",
      descripcion: "Acompañamiento operativo y funcional.",
      precio: 350.00,
      margen: 28,
      moneda: moneda_base,
      recurrencia: "Mensual",
      seccion_cotizacion: "Servicio complementario",
      cotizable: true,
      facturable: true,
      orden: 1
    }
  ].each do |attrs|
    detalle = producto_saas.producto_servicio_precios.find_or_initialize_by(nombre: attrs[:nombre])
    detalle.assign_attributes(attrs)
    detalle.save!
  end
end

producto_implementacion = ProductoServicio.find_by(codigo: "PS-IMP-003")
if producto_implementacion
  [
    {
      nombre: "Implementación inicial",
      descripcion: "Salida en vivo y parametrización.",
      precio: 6500.00,
      margen: 30,
      moneda: moneda_base,
      recurrencia: "Unico",
      seccion_cotizacion: "Cargo inicial",
      cotizable: true,
      facturable: true,
      orden: 0
    },
    {
      nombre: "Licencias de marca",
      descripcion: "Componentes externos en moneda internacional.",
      precio: 1800.00,
      margen: 18,
      moneda: moneda_dolar,
      recurrencia: "Unico",
      seccion_cotizacion: "Servicio complementario",
      cotizable: true,
      facturable: true,
      orden: 1
    }
  ].each do |attrs|
    detalle = producto_implementacion.producto_servicio_precios.find_or_initialize_by(nombre: attrs[:nombre])
    detalle.assign_attributes(attrs)
    detalle.save!
  end

  [
    {
      tipo_costo: "Implementacion",
      nombre: "Equipo técnico local",
      descripcion: "Horas de análisis, parametrización y acompañamiento.",
      monto: 2400.00,
      moneda: moneda_base,
      recurrencia: "Unico",
      orden: 0,
      activo: true
    },
    {
      tipo_costo: "Colateral",
      nombre: "Componentes de terceros",
      descripcion: "Servicios externos vinculados al despliegue.",
      monto: 600.00,
      moneda: moneda_dolar,
      recurrencia: "Unico",
      orden: 1,
      activo: true
    }
  ].each do |attrs|
    detalle = producto_implementacion.producto_servicio_costos.find_or_initialize_by(nombre: attrs[:nombre])
    detalle.assign_attributes(attrs)
    detalle.save!
  end
end
