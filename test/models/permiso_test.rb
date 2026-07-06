require "test_helper"

class PermisoTest < ActiveSupport::TestCase
  test "requiere modulo unico por rol" do
    rol = Rol.create!(nombre: "Supervisor", activo: true)
    modulo = ModuloSistema.create!(codigo: "DASHBOARD", nombre: "Dashboard", activo: true)
    # ModuloSistema.create! dispara SincronizarPermisosModulo (after_commit), que ya
    # genera un Permiso para cada rol. Usamos find_or_create_by! para no chocar con esa
    # sincronizacion automatica y garantizar que existe un permiso base para el rol.
    Permiso.find_or_create_by!(rol: rol, modulo_sistema: modulo)

    permiso = Permiso.new(rol: rol, modulo_sistema: modulo)

    assert_not permiso.valid?
    assert_includes permiso.errors[:modulo_sistema_id], "has already been taken"
  end
end
