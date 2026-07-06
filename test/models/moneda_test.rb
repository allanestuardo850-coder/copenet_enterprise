require "test_helper"

class MonedaTest < ActiveSupport::TestCase
  test "requiere codigo numerico unico" do
    Moneda.create!(codigo: 320, nombre: "Quetzal", simbolo: "Q", activo: true)

    moneda = Moneda.new(codigo: 320, nombre: "Quetzal Dos", simbolo: "Q2", activo: true)

    assert_not moneda.valid?
    assert_includes moneda.errors[:codigo], "has already been taken"
  end
end
