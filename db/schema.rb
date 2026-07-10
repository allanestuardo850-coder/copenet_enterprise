# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_06_180000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "auditoria_precio_cotizaciones", force: :cascade do |t|
    t.datetime "changed_at", null: false
    t.bigint "cotizacion_detalle_id", null: false
    t.bigint "cotizacion_id", null: false
    t.datetime "created_at", null: false
    t.decimal "new_applied_price", precision: 14, scale: 2, null: false
    t.decimal "original_price", precision: 14, scale: 2, null: false
    t.decimal "previous_applied_price", precision: 14, scale: 2
    t.string "price_rule_applied"
    t.text "reason"
    t.datetime "updated_at", null: false
    t.bigint "usuario_id"
    t.index ["cotizacion_detalle_id"], name: "index_auditoria_precio_cotizaciones_on_cotizacion_detalle_id"
    t.index ["cotizacion_id"], name: "index_auditoria_precio_cotizaciones_on_cotizacion_id"
    t.index ["usuario_id"], name: "index_auditoria_precio_cotizaciones_on_usuario_id"
  end

  create_table "bitacora_eventos", force: :cascade do |t|
    t.bigint "cliente_id"
    t.bigint "cotizacion_id"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "event_type", null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "proyecto_id"
    t.bigint "subject_id"
    t.string "subject_type"
    t.datetime "updated_at", null: false
    t.bigint "usuario_id"
    t.index ["cliente_id"], name: "index_bitacora_eventos_on_cliente_id"
    t.index ["cotizacion_id"], name: "index_bitacora_eventos_on_cotizacion_id"
    t.index ["event_type"], name: "index_bitacora_eventos_on_event_type"
    t.index ["proyecto_id"], name: "index_bitacora_eventos_on_proyecto_id"
    t.index ["subject_type", "subject_id"], name: "index_bitacora_eventos_on_subject"
    t.index ["usuario_id"], name: "index_bitacora_eventos_on_usuario_id"
  end

  create_table "clientes", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.string "client_type", default: "no_socio", null: false
    t.string "contacto_principal"
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "is_copenet_client", default: false, null: false
    t.string "nombre", null: false
    t.text "notas"
    t.string "telefono"
    t.datetime "updated_at", null: false
    t.index ["client_type"], name: "index_clientes_on_client_type"
    t.index ["is_copenet_client"], name: "index_clientes_on_is_copenet_client"
    t.index ["nombre"], name: "index_clientes_on_nombre"
  end

  create_table "cobros", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.bigint "cliente_id"
    t.string "cliente_nombre", null: false
    t.datetime "created_at", null: false
    t.string "estado", default: "en_gestion", null: false
    t.date "fecha_pago"
    t.date "fecha_vencimiento"
    t.string "gestor"
    t.bigint "moneda_id"
    t.decimal "monto", precision: 14, scale: 2, default: "0.0", null: false
    t.text "notas"
    t.string "referencia", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_cobros_on_cliente_id"
    t.index ["cliente_nombre"], name: "index_cobros_on_cliente_nombre"
    t.index ["estado"], name: "index_cobros_on_estado"
    t.index ["fecha_vencimiento"], name: "index_cobros_on_fecha_vencimiento"
    t.index ["moneda_id"], name: "index_cobros_on_moneda_id"
    t.index ["referencia"], name: "index_cobros_on_referencia", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "address"
    t.string "color_acento"
    t.string "color_primario"
    t.string "color_secundario"
    t.string "commercial_name"
    t.string "company_type"
    t.string "correo_comercial"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "fel_scenario_code"
    t.string "fel_token"
    t.string "infile_key"
    t.string "infile_prefix"
    t.string "infile_signature_key"
    t.string "infile_signature_prefix"
    t.string "legal_name"
    t.string "notification_email"
    t.string "phone"
    t.text "quote_closing_text"
    t.string "quote_contact_email"
    t.string "quote_contact_name"
    t.string "quote_contact_phone"
    t.string "quote_contact_role"
    t.string "quote_contact_text_color"
    t.text "quote_footer_note"
    t.string "quote_format_name"
    t.text "quote_intro_text"
    t.string "quote_signature_name"
    t.string "quote_signature_role"
    t.string "quote_subtitle"
    t.string "quote_table_header_color"
    t.text "quote_terms_text"
    t.string "quote_title"
    t.string "quote_website_url"
    t.string "status"
    t.string "tax_id"
    t.datetime "updated_at", null: false
    t.string "vat_affiliation"
    t.string "web"
    t.index ["commercial_name"], name: "index_companies_on_commercial_name"
    t.index ["legal_name"], name: "index_companies_on_legal_name"
    t.index ["tax_id"], name: "index_companies_on_tax_id"
  end

  create_table "configuracion_sistemas", force: :cascade do |t|
    t.string "color_acento", default: "#6eb8ff", null: false
    t.string "color_boton_texto", default: "#ffffff", null: false
    t.string "color_primario", default: "#2458e6", null: false
    t.string "color_secundario", default: "#0b2d66", null: false
    t.string "color_sidebar_desde", default: "#0a2146", null: false
    t.string "color_sidebar_hasta", default: "#08172e", null: false
    t.datetime "created_at", null: false
    t.string "footer_logo_etiqueta", default: "Visa", null: false
    t.string "footer_logo_texto", default: "VISA", null: false
    t.string "loader_mensaje", default: "Cargando plataforma...", null: false
    t.string "login_eyebrow", default: "Copenet Enterprise", null: false
    t.text "login_subtitulo", default: "Plataforma empresarial para administración, costos, cobros y control operativo.", null: false
    t.string "login_titulo", default: "Control empresarial con una base moderna y segura", null: false
    t.string "nombre_plataforma", default: "Copenet Enterprise", null: false
    t.string "nombre_principal", default: "COPENET", null: false
    t.string "nombre_secundario", default: "ENTERPRISE", null: false
    t.text "pdf_cierre_texto", default: "Quedamos a su disposición para ampliar cualquier punto de esta propuesta, validar alcances finales y preparar la activación comercial correspondiente. Una vez autorizada, esta cotización puede continuar su preparación hacia el flujo de facturación.", null: false
    t.string "pdf_firma_cargo", default: "Dirección Comercial", null: false
    t.string "pdf_firma_nombre", default: "Equipo Comercial Copenet", null: false
    t.text "pdf_intro_texto", default: "Agradecemos el interés mostrado en nuestros productos y servicios. Por medio del presente documento compartimos una propuesta comercial estructurada a partir del catálogo maestro del servicio, separando cargos iniciales, mensuales, recurrentes y complementarios cuando aplique.", null: false
    t.string "pdf_subtitulo", default: "Documento comercial generado desde el catálogo maestro del servicio.", null: false
    t.string "pdf_titulo", default: "Propuesta Comercial Autorizable", null: false
    t.string "placeholder_busqueda", default: "Buscar empresas, cuentas o reportes", null: false
    t.string "promo_boton_texto", default: "Ver planes", null: false
    t.string "promo_boton_url", default: "#", null: false
    t.text "promo_descripcion", default: "Descubre todas las funcionalidades avanzadas de Copenet Enterprise.", null: false
    t.string "promo_titulo", default: "Mejora tu experiencia", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contratos", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.bigint "cliente_id"
    t.string "cliente_nombre", null: false
    t.string "codigo", null: false
    t.datetime "created_at", null: false
    t.string "estado", default: "borrador", null: false
    t.date "fecha_fin"
    t.date "fecha_inicio"
    t.bigint "moneda_id"
    t.text "notas"
    t.string "responsable"
    t.string "tipo_contrato"
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 14, scale: 2, default: "0.0", null: false
    t.index ["cliente_id"], name: "index_contratos_on_cliente_id"
    t.index ["cliente_nombre"], name: "index_contratos_on_cliente_nombre"
    t.index ["codigo"], name: "index_contratos_on_codigo", unique: true
    t.index ["estado"], name: "index_contratos_on_estado"
    t.index ["fecha_fin"], name: "index_contratos_on_fecha_fin"
    t.index ["moneda_id"], name: "index_contratos_on_moneda_id"
  end

  create_table "costos", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.string "centro_costo"
    t.string "clasificacion"
    t.string "concepto", null: false
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.string "estado", default: "registrado", null: false
    t.date "fecha"
    t.bigint "moneda_id"
    t.decimal "monto", precision: 14, scale: 2, default: "0.0", null: false
    t.string "periodo"
    t.string "proveedor"
    t.datetime "updated_at", null: false
    t.index ["concepto"], name: "index_costos_on_concepto"
    t.index ["estado"], name: "index_costos_on_estado"
    t.index ["moneda_id"], name: "index_costos_on_moneda_id"
    t.index ["periodo"], name: "index_costos_on_periodo"
  end

  create_table "cotizacion_detalles", force: :cascade do |t|
    t.decimal "applied_price", precision: 14, scale: 2
    t.boolean "billing_authorized", default: false, null: false
    t.decimal "catalog_price", precision: 14, scale: 2
    t.bigint "cotizacion_id", null: false
    t.datetime "created_at", null: false
    t.string "descripcion", null: false
    t.decimal "discount_amount", precision: 14, scale: 2, default: "0.0", null: false
    t.text "discount_reason"
    t.boolean "facturable", default: true, null: false
    t.decimal "internal_cost", precision: 14, scale: 2
    t.boolean "manual_price_override", default: false, null: false
    t.bigint "moneda_id"
    t.integer "orden", default: 0, null: false
    t.decimal "precio", precision: 14, scale: 2, null: false
    t.text "price_override_reason"
    t.string "price_rule_applied"
    t.bigint "producto_servicio_precio_id"
    t.string "recurrencia"
    t.string "seccion_cotizacion"
    t.datetime "updated_at", null: false
    t.index ["cotizacion_id"], name: "index_cotizacion_detalles_on_cotizacion_id"
    t.index ["moneda_id"], name: "index_cotizacion_detalles_on_moneda_id"
    t.index ["orden"], name: "index_cotizacion_detalles_on_orden"
    t.index ["price_rule_applied"], name: "index_cotizacion_detalles_on_price_rule_applied"
    t.index ["producto_servicio_precio_id"], name: "index_cotizacion_detalles_on_producto_servicio_precio_id"
  end

  create_table "cotizaciones", force: :cascade do |t|
    t.text "alcance_personalizado"
    t.datetime "approved_at"
    t.text "cancellation_reason"
    t.string "cliente", null: false
    t.bigint "cliente_id"
    t.string "codigo", null: false
    t.string "contacto", null: false
    t.string "correo", null: false
    t.datetime "created_at", null: false
    t.string "estado", default: "borrador", null: false
    t.decimal "monto_descuento", precision: 14, scale: 2, default: "0.0", null: false
    t.text "observaciones"
    t.decimal "porcentaje_descuento", precision: 5, scale: 2
    t.decimal "precio_base", precision: 14, scale: 2, null: false
    t.decimal "precio_final", precision: 14, scale: 2, default: "0.0", null: false
    t.bigint "producto_servicio_id", null: false
    t.datetime "signed_at"
    t.string "signed_by"
    t.string "telefono"
    t.datetime "updated_at", null: false
    t.integer "version", default: 1, null: false
    t.integer "vigencia_dias", default: 15, null: false
    t.text "workflow_notes"
    t.index ["cliente_id"], name: "index_cotizaciones_on_cliente_id"
    t.index ["codigo"], name: "index_cotizaciones_on_codigo", unique: true
    t.index ["created_at"], name: "index_cotizaciones_on_created_at"
    t.index ["estado"], name: "index_cotizaciones_on_estado"
    t.index ["producto_servicio_id"], name: "index_cotizaciones_on_producto_servicio_id"
  end

  create_table "expediente_clientes", force: :cascade do |t|
    t.bigint "cliente_id", null: false
    t.datetime "created_at", null: false
    t.string "estado", default: "activo", null: false
    t.text "resumen"
    t.string "titulo", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_expediente_clientes_on_cliente_id"
  end

  create_table "facturas", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.bigint "cliente_id"
    t.string "cliente_nombre", null: false
    t.datetime "created_at", null: false
    t.string "estado", default: "borrador", null: false
    t.date "fecha_emision"
    t.date "fecha_vencimiento"
    t.bigint "moneda_id"
    t.text "notas"
    t.string "numero", null: false
    t.string "serie"
    t.decimal "total", precision: 14, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_facturas_on_cliente_id"
    t.index ["cliente_nombre"], name: "index_facturas_on_cliente_nombre"
    t.index ["estado"], name: "index_facturas_on_estado"
    t.index ["fecha_emision"], name: "index_facturas_on_fecha_emision"
    t.index ["moneda_id"], name: "index_facturas_on_moneda_id"
    t.index ["numero"], name: "index_facturas_on_numero", unique: true
  end

  create_table "modulo_sistemas", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.string "codigo", null: false
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.string "grupo"
    t.string "nombre", null: false
    t.string "ruta"
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_modulo_sistemas_on_codigo", unique: true
    t.index ["grupo"], name: "index_modulo_sistemas_on_grupo"
  end

  create_table "monedas", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.integer "codigo", null: false
    t.datetime "created_at", null: false
    t.string "nombre", null: false
    t.string "simbolo", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_monedas_on_codigo", unique: true
    t.index ["nombre"], name: "index_monedas_on_nombre", unique: true
  end

  create_table "permisos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "modulo_sistema_id", null: false
    t.boolean "puede_configurar", default: false, null: false
    t.boolean "puede_crear", default: false, null: false
    t.boolean "puede_editar", default: false, null: false
    t.boolean "puede_eliminar", default: false, null: false
    t.boolean "puede_exportar", default: false, null: false
    t.boolean "puede_ver", default: false, null: false
    t.bigint "rol_id", null: false
    t.datetime "updated_at", null: false
    t.index ["modulo_sistema_id"], name: "index_permisos_on_modulo_sistema_id"
    t.index ["rol_id", "modulo_sistema_id"], name: "index_permisos_on_rol_id_and_modulo_sistema_id", unique: true
    t.index ["rol_id"], name: "index_permisos_on_rol_id"
  end

  create_table "producto_servicio_costos", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.bigint "moneda_id"
    t.decimal "monto", precision: 14, scale: 2, null: false
    t.string "nombre", null: false
    t.integer "orden", default: 0, null: false
    t.bigint "producto_servicio_id", null: false
    t.string "recurrencia", null: false
    t.string "tipo_costo", null: false
    t.datetime "updated_at", null: false
    t.index ["activo"], name: "index_producto_servicio_costos_on_activo"
    t.index ["moneda_id"], name: "index_producto_servicio_costos_on_moneda_id"
    t.index ["producto_servicio_id"], name: "index_producto_servicio_costos_on_producto_servicio_id"
    t.index ["tipo_costo"], name: "index_producto_servicio_costos_on_tipo_costo"
  end

  create_table "producto_servicio_precios", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.boolean "cotizable", default: true, null: false
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.boolean "facturable", default: true, null: false
    t.decimal "margen", precision: 5, scale: 2
    t.bigint "moneda_id"
    t.string "nombre", null: false
    t.integer "orden", default: 0, null: false
    t.decimal "precio", precision: 14, scale: 2, null: false
    t.bigint "producto_servicio_id", null: false
    t.string "recurrencia"
    t.string "seccion_cotizacion"
    t.datetime "updated_at", null: false
    t.index ["activo"], name: "index_producto_servicio_precios_on_activo"
    t.index ["moneda_id"], name: "index_producto_servicio_precios_on_moneda_id"
    t.index ["orden"], name: "index_producto_servicio_precios_on_orden"
    t.index ["producto_servicio_id"], name: "index_producto_servicio_precios_on_producto_servicio_id"
  end

  create_table "producto_servicios", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.boolean "afecto_iva", default: true, null: false
    t.boolean "agrupable_en_factura", default: true, null: false
    t.boolean "allow_discount", default: false, null: false
    t.string "base_liquidacion"
    t.boolean "billable", default: true, null: false
    t.decimal "cantidad_maxima", precision: 14, scale: 2
    t.decimal "cantidad_minima", precision: 14, scale: 2
    t.text "caso_uso"
    t.string "categoria", null: false
    t.string "centro_costo_codigo"
    t.boolean "cobra_proporcional", default: false, null: false
    t.string "codigo", null: false
    t.bigint "company_id"
    t.boolean "contabilizable", default: false, null: false
    t.decimal "costo_base", precision: 14, scale: 2
    t.datetime "created_at", null: false
    t.string "cuenta_ingreso_codigo"
    t.text "descripcion"
    t.integer "dia_cobro"
    t.integer "duracion_minima_meses"
    t.boolean "es_recurrente", default: false, null: false
    t.string "estado_catalogo", default: "Borrador", null: false
    t.boolean "facturable", default: true, null: false
    t.date "fecha_fin_vigencia"
    t.date "fecha_inicio_vigencia"
    t.text "incluye_cotizacion"
    t.boolean "is_development", default: false, null: false
    t.boolean "is_implementation", default: false, null: false
    t.boolean "is_license", default: false, null: false
    t.boolean "is_recurring_service", default: false, null: false
    t.boolean "liquidable", default: false, null: false
    t.decimal "margen_objetivo", precision: 5, scale: 2
    t.string "modelo_cobro", null: false
    t.string "modelo_liquidacion"
    t.bigint "moneda_id"
    t.string "nivel_servicio"
    t.boolean "no_charge_for_copenet", default: false, null: false
    t.string "nombre", null: false
    t.string "nombre_corto"
    t.integer "orden_visual"
    t.boolean "permite_costo_variable", default: false, null: false
    t.boolean "permite_descuento", default: false, null: false
    t.boolean "permite_renovacion", default: false, null: false
    t.boolean "permite_suspension", default: false, null: false
    t.decimal "porcentaje_descuento_maximo", precision: 5, scale: 2
    t.decimal "porcentaje_liquidacion", precision: 5, scale: 2
    t.decimal "precio_base", precision: 14, scale: 2
    t.text "problema_resuelve"
    t.string "product_type"
    t.string "recurrencia"
    t.boolean "requiere_activacion", default: false, null: false
    t.boolean "requiere_aprobacion_comercial", default: false, null: false
    t.boolean "requiere_consumo", default: false, null: false
    t.boolean "requiere_contrato", default: false, null: false
    t.boolean "requiere_descripcion_dinamica", default: false, null: false
    t.boolean "requiere_fel_detallado", default: false, null: false
    t.boolean "requiere_soporte", default: false, null: false
    t.text "requisitos_cierre_venta"
    t.string "subcategoria"
    t.string "tipo_facturacion"
    t.string "tipo_impuesto"
    t.string "tipo_producto", null: false
    t.string "unidad_cobro"
    t.datetime "updated_at", null: false
    t.boolean "visible_en_contratos", default: true, null: false
    t.boolean "visible_en_crm", default: true, null: false
    t.boolean "visible_en_expedientes", default: true, null: false
    t.boolean "visible_in_quote", default: true, null: false
    t.index ["categoria"], name: "index_producto_servicios_on_categoria"
    t.index ["codigo"], name: "index_producto_servicios_on_codigo", unique: true
    t.index ["company_id"], name: "index_producto_servicios_on_company_id"
    t.index ["estado_catalogo"], name: "index_producto_servicios_on_estado_catalogo"
    t.index ["modelo_cobro"], name: "index_producto_servicios_on_modelo_cobro"
    t.index ["moneda_id"], name: "index_producto_servicios_on_moneda_id"
    t.index ["no_charge_for_copenet"], name: "index_producto_servicios_on_no_charge_for_copenet"
    t.index ["nombre"], name: "index_producto_servicios_on_nombre"
    t.index ["product_type"], name: "index_producto_servicios_on_product_type"
    t.index ["tipo_producto"], name: "index_producto_servicios_on_tipo_producto"
  end

  create_table "proyectos", force: :cascade do |t|
    t.text "checklist_asignable"
    t.bigint "cliente_id", null: false
    t.decimal "costo_interno_estimado", precision: 14, scale: 2
    t.bigint "cotizacion_id", null: false
    t.datetime "created_at", null: false
    t.text "documentacion_relacionada"
    t.string "estado", default: "pendiente_inicio", null: false
    t.bigint "expediente_cliente_id", null: false
    t.date "fecha_inicio"
    t.decimal "margen_estimado", precision: 14, scale: 2
    t.decimal "monto_aprobado", precision: 14, scale: 2
    t.decimal "monto_facturable", precision: 14, scale: 2
    t.string "nombre", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_proyectos_on_cliente_id"
    t.index ["cotizacion_id"], name: "index_proyectos_on_cotizacion_id"
    t.index ["estado"], name: "index_proyectos_on_estado"
    t.index ["expediente_cliente_id"], name: "index_proyectos_on_expediente_cliente_id"
  end

  create_table "roles", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.string "nombre", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_roles_on_nombre", unique: true
  end

  create_table "usuario_permisos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "modulo_sistema_id", null: false
    t.boolean "puede_configurar", default: false, null: false
    t.boolean "puede_crear", default: false, null: false
    t.boolean "puede_editar", default: false, null: false
    t.boolean "puede_eliminar", default: false, null: false
    t.boolean "puede_exportar", default: false, null: false
    t.boolean "puede_ver", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "usuario_id", null: false
    t.index ["modulo_sistema_id"], name: "index_usuario_permisos_on_modulo_sistema_id"
    t.index ["usuario_id", "modulo_sistema_id"], name: "index_usuario_permisos_on_usuario_id_and_modulo_sistema_id", unique: true
    t.index ["usuario_id"], name: "index_usuario_permisos_on_usuario_id"
  end

  create_table "usuario_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "rol_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "usuario_id", null: false
    t.index ["rol_id"], name: "index_usuario_roles_on_rol_id"
    t.index ["usuario_id", "rol_id"], name: "index_usuario_roles_on_usuario_id_and_rol_id", unique: true
    t.index ["usuario_id"], name: "index_usuario_roles_on_usuario_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.string "apellido", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "nombre", null: false
    t.string "password_digest", null: false
    t.boolean "root", default: false, null: false
    t.datetime "ultimo_acceso_en"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_usuarios_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "auditoria_precio_cotizaciones", "cotizacion_detalles"
  add_foreign_key "auditoria_precio_cotizaciones", "cotizaciones"
  add_foreign_key "auditoria_precio_cotizaciones", "usuarios"
  add_foreign_key "bitacora_eventos", "clientes"
  add_foreign_key "bitacora_eventos", "cotizaciones"
  add_foreign_key "bitacora_eventos", "proyectos"
  add_foreign_key "bitacora_eventos", "usuarios"
  add_foreign_key "cobros", "clientes"
  add_foreign_key "cobros", "monedas"
  add_foreign_key "contratos", "clientes"
  add_foreign_key "contratos", "monedas"
  add_foreign_key "costos", "monedas"
  add_foreign_key "cotizacion_detalles", "cotizaciones"
  add_foreign_key "cotizacion_detalles", "monedas"
  add_foreign_key "cotizacion_detalles", "producto_servicio_precios"
  add_foreign_key "cotizaciones", "clientes"
  add_foreign_key "cotizaciones", "producto_servicios"
  add_foreign_key "expediente_clientes", "clientes"
  add_foreign_key "facturas", "clientes"
  add_foreign_key "facturas", "monedas"
  add_foreign_key "permisos", "modulo_sistemas"
  add_foreign_key "permisos", "roles"
  add_foreign_key "producto_servicio_costos", "monedas"
  add_foreign_key "producto_servicio_costos", "producto_servicios"
  add_foreign_key "producto_servicio_precios", "monedas"
  add_foreign_key "producto_servicio_precios", "producto_servicios"
  add_foreign_key "producto_servicios", "companies"
  add_foreign_key "producto_servicios", "monedas"
  add_foreign_key "proyectos", "clientes"
  add_foreign_key "proyectos", "cotizaciones"
  add_foreign_key "proyectos", "expediente_clientes"
  add_foreign_key "usuario_permisos", "modulo_sistemas"
  add_foreign_key "usuario_permisos", "usuarios"
  add_foreign_key "usuario_roles", "roles"
  add_foreign_key "usuario_roles", "usuarios"
end
