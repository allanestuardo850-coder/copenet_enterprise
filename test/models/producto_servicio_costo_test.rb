require "test_helper"

class ProductoServicioCostoTest < ActiveSupport::TestCase
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

  test "requiere tipo, nombre, monto y recurrencia validos" do
    costo = ProductoServicioCosto.new(
      producto_servicio: build_producto_servicio,
      tipo_costo: nil,
      nombre: "",
      monto: -1,
      recurrencia: "Cada dos horas"
    )

    assert_not costo.valid?
    assert_includes costo.errors[:tipo_costo], "can't be blank"
    assert_includes costo.errors[:nombre], "can't be blank"
    assert_includes costo.errors[:monto], "must be greater than or equal to 0"
    assert_includes costo.errors[:recurrencia], "is not included in the list"
  end

  test "sincroniza el costo base del producto al guardar" do
    producto_servicio = build_producto_servicio(codigo: "CO-00003-2026")
    producto_servicio.save!

    ProductoServicioCosto.create!(
      producto_servicio: producto_servicio,
      tipo_costo: "Licencia",
      nombre: "Motor principal",
      monto: 125.75,
      recurrencia: "Mensual",
      activo: true,
      orden: 0
    )

    producto_servicio.reload
    assert_equal BigDecimal("125.75"), producto_servicio.costo_base
  end
end
