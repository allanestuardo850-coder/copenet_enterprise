require "test_helper"

class UsuarioPermisoTest < ActiveSupport::TestCase
  test "requiere modulo unico por usuario" do
    usuario = Usuario.create!(
      nombre: "Ana",
      apellido: "Paz",
      email: "ana.paz@example.com",
      password: "Admin123!",
      password_confirmation: "Admin123!",
      activo: true
    )
    modulo = ModuloSistema.create!(codigo: "USUARIOS_TEST", nombre: "Usuarios Test", activo: true)
    UsuarioPermiso.create!(usuario: usuario, modulo_sistema: modulo)

    permiso = UsuarioPermiso.new(usuario: usuario, modulo_sistema: modulo)

    assert_not permiso.valid?
    assert_includes permiso.errors[:modulo_sistema_id], "has already been taken"
  end
end
