class EnterpriseController < ApplicationController
  def dashboard
    @current_page = :dashboard
    @page_title = "Dashboard"
    @page_description = nil
    @page_period = "Mayo 2024"
    @page_action = { label: "Actualizar datos", href: dashboard_path }
    @kpis = [
      { title: "Ingresos del mes", value: "Q254,900", change: "12.8%", compare: "vs abril 2024", trend: "up", tone: "success", icon: "trending-up" },
      { title: "Cobros aplicados", value: "Q91,240", change: "7.8%", compare: "vs abril 2024", trend: "up", tone: "primary", icon: "dollar" },
      { title: "Facturas emitidas", value: "1,284", change: "10.0%", compare: "vs abril 2024", trend: "up", tone: "info", icon: "file-text" },
      { title: "Cobros vencidos", value: "Q28,630", change: "4.9%", compare: "vs abril 2024", trend: "down", tone: "warning", icon: "alert" },
      { title: "Utilidad estimada", value: "Q58,430", change: "3.4%", compare: "vs abril 2024", trend: "up", tone: "success", icon: "credit-card" }
    ]
    @finance = {
      months: %w[Ene Feb Mar Abr May],
      ingresos: [258, 255, 210, 246, 256],
      costos: [110, 122, 96, 106, 112],
      utilidad: [104, 122, 95, 118, 112],
      max: 300
    }
    @pendientes = [
      { icon: "coins-stack", title: "28 cobros vencidos", detail: "Total por cobrar Q28,630", status: "Alerta", tone: "danger" },
      { icon: "calendar", title: "6 contratos por vencer", detail: "Próximos 30 días", status: "Atención", tone: "warning" },
      { icon: "file-text", title: "12 facturas pendientes de emisión", detail: "Por un valor de Q12,350", status: "Pendiente", tone: "primary" },
      { icon: "user-group", title: "5 cuentas nuevas por validar", detail: "Requieren revisión y aprobación", status: "Revisión", tone: "success" }
    ]
    @cartera = {
      segments: [
        { label: "Cobro vigente", value: 96_400, display: "Q96,400", pct: "41.3%", tone: "success" },
        { label: "En gestión", value: 72_130, display: "Q72,130", pct: "30.9%", tone: "primary" },
        { label: "Vencida", value: 64_670, display: "Q64,670", pct: "27.8%", tone: "warning" }
      ],
      total: "Q233,200"
    }
    @tendencia = {
      months: %w[Dic Ene Feb Mar Abr May],
      max: 300,
      series: [
        { label: "Facturación", total: "Q1,284,300", tone: "primary", values: [150, 152, 158, 235, 250, 256] },
        { label: "Cobros", total: "Q979,420", tone: "success", values: [120, 126, 132, 176, 196, 206] },
        { label: "Utilidad", total: "Q234,870", tone: "info", values: [60, 62, 66, 82, 78, 82] }
      ]
    }
    @modules = [
      { title: "Empresas", description: "Administra clientes corporativos, sucursales y estados operativos.", href: companies_path, icon: "building" },
      { title: "Cuentas", description: "Centraliza cuentas comerciales, financieras y de control interno.", href: accounts_path, icon: "wallet" },
      { title: "Productos y Servicios", description: "Organiza el catálogo comercial de cobros, licencias y cargos recurrentes.", href: productos_servicios_path, icon: "box" },
      { title: "Costos", description: "Supervisa egresos, centros de costo y márgenes proyectados.", href: costs_path, icon: "coins" },
      { title: "Cobros", description: "Da seguimiento a cartera, vencimientos y recuperaciones.", href: collections_path, icon: "receipt" },
      { title: "Facturación", description: "Monitorea emisión, estados y cumplimiento de facturas.", href: invoices_path, icon: "invoice" },
      { title: "Contratos", description: "Controla acuerdos, renovaciones y hitos de servicio.", href: contracts_path, icon: "contract" },
      { title: "Reportes", description: "Accede a paneles ejecutivos y cortes operativos.", href: reports_path, icon: "report" },
      { title: "Configuración", description: "Ajusta parámetros generales y catálogos visuales.", href: settings_path, icon: "settings" }
    ]
  end

  def companies
    set_module_page(
      key: :companies,
      title: "Empresas",
      description: "Visualiza empresas registradas, segmento, estado y crecimiento comercial.",
      action_label: "Nueva empresa",
      filters: ["Estado", "Segmento", "Responsable"],
      table_columns: ["Empresa", "Segmento", "Sucursal principal", "Estado", "Ingresos"],
      rows: [
        ["Grupo Aurora", "Corporativo", "Ciudad Central", "Activa", "$82,400"],
        ["Nova Logistics", "Operaciones", "Zona Norte", "Activa", "$41,880"],
        ["Finaxis Partners", "Finanzas", "Torre Empresarial", "Prospecto", "$19,540"]
      ],
      empty_title: "Aún no hay empresas reales cargadas",
      empty_description: "Esta vista ya está preparada para integrar listados de empresas cuando conectemos el backend."
    )
  end

  def accounts
    set_module_page(
      key: :accounts,
      title: "Cuentas",
      description: "Supervisa cuentas activas, ciclos de facturación y saldos de seguimiento.",
      action_label: "Nueva cuenta",
      filters: ["Tipo", "Estado", "Ciclo"],
      table_columns: ["Cuenta", "Empresa", "Tipo", "Estado", "Saldo"],
      rows: [
        ["AC-1001", "Grupo Aurora", "Comercial", "Activa", "$12,800"],
        ["AC-1002", "Nova Logistics", "Operativa", "Pendiente", "$4,120"],
        ["AC-1003", "Finaxis Partners", "Estratégica", "Activa", "$8,760"]
      ],
      empty_title: "Sin cuentas conectadas aún",
      empty_description: "La estructura visual está lista para mostrar cuentas, balances y estados cuando exista persistencia."
    )
  end

  def parametros
    @current_page = :parametros
    @configuracion_sistema = ConfiguracionSistema.first || ConfiguracionSistema.new
  end

  def actualizar_parametros
    @current_page = :parametros
    @configuracion_sistema = ConfiguracionSistema.first || ConfiguracionSistema.new
    @configuracion_sistema.assign_attributes(configuracion_sistema_params)

    if @configuracion_sistema.save
      redirect_to parametros_path, notice: "Branding y parámetros visuales actualizados correctamente."
    else
      render :parametros, status: :unprocessable_entity
    end
  end

  def auditoria
    set_module_page(
      key: :auditoria,
      title: "Auditoría",
      description: "Consulta eventos, cambios críticos y trazabilidad operativa del sistema.",
      action_label: "Exportar auditoría",
      filters: ["Usuario", "Módulo", "Fecha"],
      table_columns: ["Evento", "Módulo", "Usuario", "Fecha", "Estado"],
      rows: [
        ["Actualización de rol", "Roles y Permisos", "Root Sistema", "05 Jul 2026", "Registrado"],
        ["Cambio de empresa", "Empresas", "Administrador", "04 Jul 2026", "Registrado"],
        ["Guardado de permisos", "Usuarios", "Administrador", "04 Jul 2026", "Registrado"]
      ],
      empty_title: "Auditoría visual preparada",
      empty_description: "La vista ya está lista para enlazar eventos reales y trazabilidad transaccional."
    )
  end

  def costs
    set_module_page(
      key: :costs,
      title: "Costos",
      description: "Control visual de costos operativos, administrativos y asociados por módulo.",
      action_label: "Registrar costo",
      filters: ["Centro de costo", "Periodo", "Clasificación"],
      table_columns: ["Concepto", "Centro", "Periodo", "Estado", "Monto"],
      rows: [
        ["Infraestructura cloud", "TI", "Julio 2026", "Registrado", "$5,800"],
        ["Transporte operativo", "Logística", "Julio 2026", "Pendiente", "$2,140"],
        ["Servicios profesionales", "Administración", "Julio 2026", "Aprobado", "$3,460"]
      ],
      empty_title: "Todavía no hay costos reales registrados",
      empty_description: "La vista ya está lista para mostrar costos por empresa, centro y periodo."
    )
  end

  def collections
    set_module_page(
      key: :collections,
      title: "Cobros",
      description: "Da seguimiento a cobros, vencimientos, promesas de pago y recuperación de cartera.",
      action_label: "Registrar cobro",
      filters: ["Estado", "Vencimiento", "Gestor"],
      table_columns: ["Referencia", "Cliente", "Vencimiento", "Estado", "Monto"],
      rows: [
        ["CB-441", "Grupo Aurora", "05 Jul 2026", "Cobrado", "$6,240"],
        ["CB-442", "Nova Logistics", "11 Jul 2026", "En gestión", "$3,180"],
        ["CB-443", "Finaxis Partners", "02 Jul 2026", "Vencido", "$1,920"]
      ],
      empty_title: "Sin cobranzas sincronizadas",
      empty_description: "Podremos conectar aquí la cartera y su avance sin rehacer la interfaz."
    )
  end

  def invoices
    set_module_page(
      key: :invoices,
      title: "Facturación",
      description: "Panel visual para facturas emitidas, pendientes, enviadas y conciliadas.",
      action_label: "Emitir factura",
      filters: ["Estado", "Serie", "Periodo"],
      table_columns: ["Factura", "Cliente", "Fecha", "Estado", "Total"],
      rows: [
        ["INV-2048", "Grupo Aurora", "01 Jul 2026", "Emitida", "$9,450"],
        ["INV-2049", "Nova Logistics", "03 Jul 2026", "Borrador", "$2,780"],
        ["INV-2050", "Finaxis Partners", "04 Jul 2026", "Enviada", "$5,610"]
      ],
      empty_title: "Facturación lista para integrarse",
      empty_description: "Esta vista está preparada para mostrar ciclos, series y estados de facturación."
    )
  end

  def contracts
    set_module_page(
      key: :contracts,
      title: "Contratos",
      description: "Supervisa contratos activos, renovaciones, vigencias y compromisos comerciales.",
      action_label: "Nuevo contrato",
      filters: ["Estado", "Vigencia", "Tipo"],
      table_columns: ["Contrato", "Cliente", "Inicio", "Estado", "Valor"],
      rows: [
        ["CT-301", "Grupo Aurora", "01 Ene 2026", "Activo", "$42,000"],
        ["CT-302", "Nova Logistics", "15 Mar 2026", "Renovación", "$18,500"],
        ["CT-303", "Finaxis Partners", "20 Jun 2026", "Borrador", "$27,900"]
      ],
      empty_title: "Sin contratos persistidos todavía",
      empty_description: "La capa visual ya está preparada para contratos, anexos y renovaciones."
    )
  end

  def reports
    set_module_page(
      key: :reports,
      title: "Reportes",
      description: "Centraliza vistas ejecutivas, reportes operativos y métricas consolidadas.",
      action_label: "Generar reporte",
      filters: ["Área", "Periodo", "Formato"],
      table_columns: ["Reporte", "Área", "Frecuencia", "Última ejecución", "Estado"],
      rows: [
        ["Resumen financiero", "Dirección", "Mensual", "04 Jul 2026", "Disponible"],
        ["Eficiencia operativa", "Operaciones", "Semanal", "03 Jul 2026", "Programado"],
        ["Cartera consolidada", "Cobros", "Diario", "05 Jul 2026", "Disponible"]
      ],
      empty_title: "Sin reportes conectados a datos reales",
      empty_description: "Aquí irán dashboards, exportaciones y cortes automáticos del sistema."
    )
  end

  def settings
    set_module_page(
      key: :settings,
      title: "Configuración",
      description: "Ajusta parámetros visuales, preferencias operativas y módulos habilitados.",
      action_label: "Guardar preferencias",
      filters: ["Área", "Tipo", "Estado"],
      table_columns: ["Parámetro", "Sección", "Modo", "Estado", "Última actualización"],
      rows: [
        ["Tema visual", "Interfaz", "Automático", "Activo", "05 Jul 2026"],
        ["Moneda base", "Finanzas", "USD", "Activo", "02 Jul 2026"],
        ["Notificaciones", "Sistema", "Resumen diario", "Activo", "04 Jul 2026"]
      ],
      empty_title: "Configuración visual preparada",
      empty_description: "La página ya puede recibir catálogos y preferencias cuando se modele el backend."
    )
  end

  private

  def configuracion_sistema_params
    params.require(:configuracion_sistema).permit(
      :nombre_plataforma,
      :nombre_principal,
      :nombre_secundario,
      :login_eyebrow,
      :login_titulo,
      :login_subtitulo,
      :promo_titulo,
      :promo_descripcion,
      :promo_boton_texto,
      :promo_boton_url,
      :footer_logo_texto,
      :footer_logo_etiqueta,
      :placeholder_busqueda,
      :loader_mensaje,
      :pdf_titulo,
      :pdf_subtitulo,
      :pdf_intro_texto,
      :pdf_cierre_texto,
      :pdf_firma_nombre,
      :pdf_firma_cargo,
      :color_primario,
      :color_secundario,
      :color_acento,
      :color_sidebar_desde,
      :color_sidebar_hasta,
      :color_boton_texto,
      :logo_principal,
      :logo_login,
      :logo_footer,
      :eliminar_logo_principal,
      :eliminar_logo_login,
      :eliminar_logo_footer
    )
  end

  def set_module_page(key:, title:, description:, action_label:, filters:, table_columns:, rows:, empty_title:, empty_description:)
    @current_page = key
    @page_title = title
    @page_description = description
    @page_action = { label: action_label, href: "#" }
    @page_filters = filters
    @table_columns = table_columns
    @table_rows = rows
    @empty_state = { title: empty_title, description: empty_description }
    render :module_page
  end
end
