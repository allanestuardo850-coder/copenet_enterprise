require "test_helper"

class PermisoTest < ActiveSupport::TestCase
  test "requiere modulo unico por rol" do
    rol = Rol.create!(nombre: "Supervisor", activo: true)
    modulo = ModuloSistema.create!(codigo: "DASHBOARD", nombre: "Dashboard", activo: true)
    Permiso.create!(rol: rol, modulo_sistema: modulo)

    permiso = Permiso.new(rol: rol, modulo_sistema: modulo)

    assert_not permiso.valid?
    assert_includes permiso.errors[:modulo_sistema_id], "has already been taken"
  end
end
