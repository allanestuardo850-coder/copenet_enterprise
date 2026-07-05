require "test_helper"

class RolTest < ActiveSupport::TestCase
  test "requiere nombre unico" do
    Rol.create!(nombre: "Administrador", activo: true)
    rol = Rol.new(nombre: "Administrador", activo: true)

    assert_not rol.valid?
    assert_includes rol.errors[:nombre], "has already been taken"
  end
end
