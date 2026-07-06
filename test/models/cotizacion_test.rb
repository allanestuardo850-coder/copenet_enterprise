require "test_helper"

class CotizacionTest < ActiveSupport::TestCase
  def build_producto_servicio(attrs = {})
    ProductoServicio.new(
      codigo: "CO-00001-2026",
      nombre: "Licencia Base",
      tipo_producto: "Licencia",
      categoria: "Cobro recurrente",
      modelo_cobro: "Recurrente",
      estado_catalogo: "Aprobado",
      facturable: true,
      tipo_facturacion: "Anticipada",
      es_recurrente: true,
      recurrencia: "Mensual",
      afecto_iva: true,
      tipo_impuesto: "IVA"
    ).tap do |producto_servicio|
      producto_servicio.assign_attributes(attrs)
    end
  end

  def create_cliente(attrs = {})
    Cliente.create!(
      {
        nombre: "Cliente Demo",
        contacto_principal: "Maria Perez",
        email: "maria@example.com",
        telefono: "+502 5555-5555",
        client_type: "no_socio",
        is_copenet_client: false
      }.merge(attrs)
    )
  end

  test "calcula subtotal y total final desde varios items" do
    cliente = create_cliente
    cotizacion = Cotizacion.new(
      producto_servicio: build_producto_servicio,
      cliente_registro: cliente,
      codigo: "CTZ-00001-2026",
      contacto: "Maria Perez",
      correo: "maria@example.com",
      telefono: "+502 5555-5555",
      vigencia_dias: 15,
      porcentaje_descuento: 10
    )

    cotizacion.cotizacion_detalles.build(descripcion: "Licencia mensual", precio: 100, orden: 0)
    cotizacion.cotizacion_detalles.build(descripcion: "Implementación inicial", precio: 50, orden: 1)

    assert cotizacion.valid?
    assert_equal BigDecimal("150.0"), cotizacion.precio_base
    assert_equal BigDecimal("15.0"), cotizacion.monto_descuento
    assert_equal BigDecimal("135.0"), cotizacion.precio_final
  end

  test "requiere al menos un item" do
    cliente = create_cliente(email: "demo2@example.com")
    cotizacion = Cotizacion.new(
      producto_servicio: build_producto_servicio,
      cliente_registro: cliente,
      codigo: "CTZ-00002-2026",
      contacto: "Maria Perez",
      correo: "maria@example.com",
      telefono: "+502 5555-5555",
      vigencia_dias: 15
    )

    assert_not cotizacion.valid?
    assert_includes cotizacion.errors[:base], "Debes agregar al menos un ítem a la cotización"
  end

  test "no permite descuento global cuando la cotizacion mezcla monedas" do
    producto_servicio = build_producto_servicio
    cliente = create_cliente(email: "demo3@example.com")
    quetzal = Moneda.create!(codigo: 3200, nombre: "Quetzal Test", simbolo: "Q")
    dolar = Moneda.create!(codigo: 8400, nombre: "Dolar Test", simbolo: "$")

    cotizacion = Cotizacion.new(
      producto_servicio: producto_servicio,
      cliente_registro: cliente,
      codigo: "CTZ-00003-2026",
      contacto: "Maria Perez",
      correo: "maria@example.com",
      telefono: "+502 5555-5555",
      vigencia_dias: 15,
      porcentaje_descuento: 10
    )

    cotizacion.cotizacion_detalles.build(descripcion: "Setup", precio: 100, orden: 0, moneda: quetzal)
    cotizacion.cotizacion_detalles.build(descripcion: "Licencia internacional", precio: 50, orden: 1, moneda: dolar)

    assert_not cotizacion.valid?
    assert_includes cotizacion.errors[:porcentaje_descuento], "no puede aplicarse de forma global cuando la cotización mezcla monedas"
  end

  test "cliente copenet con producto sin cobro aplica precio cero" do
    cliente = create_cliente(client_type: "copenet", is_copenet_client: true, email: "copenet@example.com")
    producto = build_producto_servicio(no_charge_for_copenet: true, costo_base: 40, precio_base: 100)

    cotizacion = Cotizacion.new(
      producto_servicio: producto,
      cliente_registro: cliente,
      codigo: "CTZ-00004-2026",
      contacto: "Maria Perez",
      correo: "maria@example.com",
      telefono: "+502 5555-5555",
      vigencia_dias: 15
    )
    cotizacion.cotizacion_detalles.build(descripcion: "Implementación", catalog_price: 100, applied_price: 100, precio: 100, internal_cost: 40, orden: 0)

    assert cotizacion.valid?
    detalle = cotizacion.cotizacion_detalles.first
    assert_equal BigDecimal("0.0"), detalle.applied_price
    assert_equal "NO_CHARGE_COPENET", detalle.price_rule_applied
    assert_equal BigDecimal("100.0"), cotizacion.total_no_cobrado_copenet
    assert_equal BigDecimal("0.0"), cotizacion.total_facturable
  end

  test "cliente no socio mantiene precio catalogo" do
    cliente = create_cliente(email: "nosocio@example.com")
    producto = build_producto_servicio(no_charge_for_copenet: true, costo_base: 40, precio_base: 100)

    cotizacion = Cotizacion.new(
      producto_servicio: producto,
      cliente_registro: cliente,
      codigo: "CTZ-00005-2026",
      contacto: "Maria Perez",
      correo: "maria@example.com",
      telefono: "+502 5555-5555",
      vigencia_dias: 15
    )
    cotizacion.cotizacion_detalles.build(descripcion: "Implementación", catalog_price: 100, applied_price: 100, precio: 100, internal_cost: 40, orden: 0)

    assert cotizacion.valid?
    detalle = cotizacion.cotizacion_detalles.first
    assert_equal BigDecimal("100.0"), detalle.applied_price
    assert_equal "CATALOG_PRICE", detalle.price_rule_applied
  end

  test "cotizacion firmada genera proyecto y expediente" do
    cliente = create_cliente(email: "firmada@example.com")
    producto = build_producto_servicio(codigo: "CO-00999-2026", precio_base: 100, costo_base: 25)
    producto.save!

    cotizacion = Cotizacion.new(
      producto_servicio: producto,
      cliente_registro: cliente,
      codigo: "CTZ-00006-2026",
      contacto: "Maria Perez",
      correo: "maria@example.com",
      telefono: "+502 5555-5555",
      vigencia_dias: 15
    )
    cotizacion.cotizacion_detalles.build(descripcion: "Licencia mensual", catalog_price: 100, applied_price: 100, precio: 100, internal_cost: 25, orden: 0)
    cotizacion.save!

    assert_difference -> { Proyecto.count }, 1 do
      cotizacion.update!(estado: "firmada")
    end

    proyecto = Proyecto.last
    assert_equal cotizacion, proyecto.cotizacion
    assert_equal cliente, proyecto.cliente
    assert_equal cliente.expediente_cliente, proyecto.expediente_cliente
  end

  test "cambio manual de precio genera auditoria" do
    cliente = create_cliente(email: "audit@example.com")
    producto = build_producto_servicio(codigo: "CO-01000-2026", precio_base: 100, costo_base: 30)
    producto.save!
    usuario = Usuario.create!(nombre: "Ana", apellido: "Admin", email: "ana.audit@example.com", password: "Admin123!2026", password_confirmation: "Admin123!2026", activo: true)

    cotizacion = Cotizacion.new(
      producto_servicio: producto,
      cliente_registro: cliente,
      codigo: "CTZ-00007-2026",
      contacto: "Maria Perez",
      correo: "maria@example.com",
      telefono: "+502 5555-5555",
      vigencia_dias: 15
    )
    cotizacion.current_usuario = usuario
    cotizacion.cotizacion_detalles.build(
      descripcion: "Licencia mensual",
      catalog_price: 100,
      applied_price: 80,
      precio: 80,
      internal_cost: 30,
      price_override_reason: "Descuento comercial autorizado",
      orden: 0
    )

    assert_difference -> { AuditoriaPrecioCotizacion.count }, 1 do
      cotizacion.save!
    end

    auditoria = AuditoriaPrecioCotizacion.last
    assert_equal BigDecimal("100.0"), auditoria.original_price
    assert_equal BigDecimal("80.0"), auditoria.new_applied_price
  end

  test "cotizacion firmada no puede modificarse directamente" do
    cliente = create_cliente(email: "locked@example.com")
    producto = build_producto_servicio(codigo: "CO-01001-2026", precio_base: 100, costo_base: 20)
    producto.save!

    cotizacion = Cotizacion.new(
      producto_servicio: producto,
      cliente_registro: cliente,
      codigo: "CTZ-00008-2026",
      contacto: "Maria Perez",
      correo: "maria@example.com",
      telefono: "+502 5555-5555",
      vigencia_dias: 15,
      estado: "firmada"
    )
    cotizacion.cotizacion_detalles.build(descripcion: "Licencia mensual", catalog_price: 100, applied_price: 100, precio: 100, internal_cost: 20, orden: 0)
    cotizacion.save!

    assert_not cotizacion.update(contacto: "Otro contacto")
    assert_includes cotizacion.errors[:base], "La cotización firmada no puede modificarse directamente. Debes crear una nueva versión."
  end
end
