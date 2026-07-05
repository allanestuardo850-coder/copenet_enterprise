require "test_helper"

class UsuarioTest < ActiveSupport::TestCase
  test "requiere datos basicos y email valido" do
    usuario = Usuario.new

    assert_not usuario.valid?
    assert_includes usuario.errors[:nombre], "can't be blank"
    assert_includes usuario.errors[:apellido], "can't be blank"
    assert_includes usuario.errors[:email], "can't be blank"
  end

  test "requiere password al crear" do
    usuario = Usuario.new(nombre: "Ana", apellido: "Perez", email: "ana@example.com")

    assert_not usuario.valid?
    assert_includes usuario.errors[:password], "can't be blank"
  end
end
