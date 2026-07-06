require "test_helper"

class ProductoServicioTest < ActiveSupport::TestCase
  def build_producto_servicio(attrs = {})
    ProductoServicio.new(
      codigo: "PS-001",
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

  test "requiere recurrencia cuando es recurrente" do
    producto_servicio = build_producto_servicio(recurrencia: nil)

    assert_not producto_servicio.valid?
    assert_includes producto_servicio.errors[:recurrencia], "can't be blank"
  end

  test "no permite dia de cobro para modelo transaccional" do
    producto_servicio = build_producto_servicio(
      es_recurrente: false,
      recurrencia: nil,
      modelo_cobro: "Transaccional",
      dia_cobro: 15
    )

    assert_not producto_servicio.valid?
    assert_includes producto_servicio.errors[:dia_cobro], "no aplica para productos transaccionales"
  end

  test "requiere tipo de facturacion cuando es facturable" do
    producto_servicio = build_producto_servicio(tipo_facturacion: nil)

    assert_not producto_servicio.valid?
    assert_includes producto_servicio.errors[:tipo_facturacion], "can't be blank"
  end

  test "recalcula costo base con costos detallados activos" do
    producto_servicio = build_producto_servicio(costo_base: 10)
    producto_servicio.producto_servicio_costos.build(
      tipo_costo: "Licencia",
      nombre: "Motor transaccional",
      monto: 45.50,
      recurrencia: "Mensual",
      activo: true
    )
    producto_servicio.producto_servicio_costos.build(
      tipo_costo: "Soporte",
      nombre: "Mesa de ayuda",
      monto: 19.50,
      recurrencia: "Mensual",
      activo: true
    )
    producto_servicio.producto_servicio_costos.build(
      tipo_costo: "Comision",
      nombre: "Comision interna",
      monto: 99.99,
      recurrencia: "Mensual",
      activo: false
    )

    assert producto_servicio.valid?
    assert_equal BigDecimal("65.0"), producto_servicio.costo_base
  end

  test "recalcula precio base y margen objetivo con precios comerciales activos" do
    producto_servicio = build_producto_servicio(precio_base: 10, margen_objetivo: 5)
    producto_servicio.producto_servicio_precios.build(
      nombre: "Licencia Enterprise",
      precio: 150,
      margen: 30,
      recurrencia: "Mensual",
      seccion_cotizacion: "Cargo mensual",
      cotizable: true,
      facturable: true,
      activo: true
    )
    producto_servicio.producto_servicio_precios.build(
      nombre: "Soporte premium",
      precio: 50,
      margen: 20,
      recurrencia: "Mensual",
      seccion_cotizacion: "Servicio complementario",
      cotizable: true,
      facturable: true,
      activo: true
    )
    producto_servicio.producto_servicio_precios.build(
      nombre: "Cargo inactivo",
      precio: 999,
      margen: 99,
      recurrencia: "Unico",
      seccion_cotizacion: "Cargo inicial",
      cotizable: true,
      facturable: true,
      activo: false
    )

    assert producto_servicio.valid?
    assert_equal BigDecimal("200.0"), producto_servicio.precio_base
    assert_equal BigDecimal("25.0"), producto_servicio.margen_objetivo
  end

  test "limpia totales consolidados cuando ya no hay precios ni costos activos" do
    producto_servicio = build_producto_servicio(
      precio_base: 200,
      costo_base: 75,
      margen_objetivo: 30
    )
    producto_servicio.producto_servicio_precios.build(
      nombre: "Cargo suspendido",
      precio: 200,
      margen: 30,
      recurrencia: "Mensual",
      seccion_cotizacion: "Cargo mensual",
      cotizable: true,
      facturable: true,
      activo: false
    )
    producto_servicio.producto_servicio_costos.build(
      tipo_costo: "Licencia",
      nombre: "Costo suspendido",
      monto: 75,
      recurrencia: "Mensual",
      activo: false
    )

    assert producto_servicio.valid?
    assert_equal BigDecimal("0.0"), producto_servicio.precio_base
    assert_equal BigDecimal("0.0"), producto_servicio.costo_base
    assert_nil producto_servicio.margen_objetivo
  end
end
