require "test_helper"

class ProductoServicioPrecioTest < ActiveSupport::TestCase
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

  test "requiere nombre y precio valido" do
    precio = ProductoServicioPrecio.new(
      producto_servicio: build_producto_servicio,
      nombre: "",
      precio: -1
    )

    assert_not precio.valid?
    assert_includes precio.errors[:nombre], "can't be blank"
    assert_includes precio.errors[:precio], "must be greater than or equal to 0"
  end

  test "sincroniza el precio base y margen del producto al guardar" do
    producto_servicio = build_producto_servicio(codigo: "CO-00002-2026")
    producto_servicio.save!

    ProductoServicioPrecio.create!(
      producto_servicio: producto_servicio,
      nombre: "Licencia Enterprise",
      precio: 250,
      margen: 35,
      recurrencia: "Mensual",
      seccion_cotizacion: "Cargo mensual",
      cotizable: true,
      facturable: true,
      activo: true,
      orden: 0
    )

    producto_servicio.reload
    assert_equal BigDecimal("250.0"), producto_servicio.precio_base
    assert_equal BigDecimal("35.0"), producto_servicio.margen_objetivo
  end
end
