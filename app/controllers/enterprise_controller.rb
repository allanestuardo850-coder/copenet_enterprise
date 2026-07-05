class EnterpriseController < ApplicationController
  before_action :set_navigation

  def dashboard
    @current_page = :dashboard
    @page_title = "Dashboard"
    @page_description = "Vista ejecutiva con indicadores financieros y operativos de la plataforma."
    @page_action = { label: "Exportar resumen", href: "#" }
    @kpis = [
      { title: "Total ingresos", value: "$248,900", change: "+12.4%", trend: "up", tone: "primary" },
      { title: "Cobros del mes", value: "$91,240", change: "+7.1%", trend: "up", tone: "success" },
      { title: "Facturas emitidas", value: "1,284", change: "+18.0%", trend: "up", tone: "primary" },
      { title: "Cuentas activas", value: "326", change: "+4 nuevas", trend: "up", tone: "info" },
      { title: "Cobros vencidos", value: "28", change: "-6.5%", trend: "down", tone: "warning" },
      { title: "Utilidad estimada", value: "$58,430", change: "+9.8%", trend: "up", tone: "success" }
    ]
    @modules = [
      { title: "Empresas", description: "Administra clientes corporativos, sucursales y estados operativos.", href: companies_path, icon: "building" },
      { title: "Cuentas", description: "Centraliza cuentas comerciales, financieras y de control interno.", href: accounts_path, icon: "wallet" },
      { title: "Servicios / Productos", description: "Organiza el portafolio comercial y los paquetes activos.", href: services_path, icon: "box" },
      { title: "Costos", description: "Supervisa egresos, centros de costo y márgenes proyectados.", href: costs_path, icon: "coins" },
      { title: "Cobros", description: "Da seguimiento a cartera, vencimientos y recuperaciones.", href: collections_path, icon: "receipt" },
      { title: "Facturación", description: "Monitorea emisión, estados y cumplimiento de facturas.", href: invoices_path, icon: "invoice" },
      { title: "Contratos", description: "Controla acuerdos, renovaciones y hitos de servicio.", href: contracts_path, icon: "contract" },
      { title: "Reportes", description: "Accede a paneles ejecutivos y cortes operativos.", href: reports_path, icon: "report" },
      { title: "Configuración", description: "Ajusta parámetros generales y catálogos visuales.", href: settings_path, icon: "settings" }
    ]
    @recent_activity = [
      { item: "Cobro aplicado a Grupo Aurora", detail: "Colección automática confirmada", status: "Completado", tone: "success" },
      { item: "Factura INV-2048 generada", detail: "Facturación mensual de servicios cloud", status: "Emitida", tone: "primary" },
      { item: "Contrato de soporte por vencer", detail: "Renovación requerida en 5 días", status: "Atención", tone: "warning" },
      { item: "Carga de costos operativos", detail: "Registro consolidado del área logística", status: "En revisión", tone: "info" }
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

  def services
    set_module_page(
      key: :services,
      title: "Servicios / Productos",
      description: "Presenta el catálogo comercial y los servicios disponibles para operación y facturación.",
      action_label: "Nuevo servicio",
      filters: ["Categoría", "Estado", "Modalidad"],
      table_columns: ["Servicio", "Categoría", "Plan", "Estado", "Precio base"],
      rows: [
        ["Soporte Enterprise", "Servicios", "Premium", "Activo", "$420"],
        ["Monitoreo Operativo", "Servicios", "Mensual", "Activo", "$275"],
        ["Suite Administrativa", "Producto", "Anual", "Borrador", "$980"]
      ],
      empty_title: "Catálogo en preparación",
      empty_description: "Aquí podremos conectar los servicios, productos y paquetes reutilizables del sistema."
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

  def set_navigation
    @navigation_items = [
      { key: :dashboard, label: "Dashboard", path: dashboard_path, icon: "dashboard" },
      { key: :companies, label: "Empresas", path: companies_path, icon: "building" },
      { key: :accounts, label: "Cuentas", path: accounts_path, icon: "wallet" },
      { key: :services, label: "Servicios / Productos", path: services_path, icon: "box" },
      { key: :costs, label: "Costos", path: costs_path, icon: "coins" },
      { key: :collections, label: "Cobros", path: collections_path, icon: "receipt" },
      { key: :invoices, label: "Facturación", path: invoices_path, icon: "invoice" },
      { key: :contracts, label: "Contratos", path: contracts_path, icon: "contract" },
      { key: :reports, label: "Reportes", path: reports_path, icon: "report" },
      { key: :settings, label: "Configuración", path: settings_path, icon: "settings" }
    ]
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
