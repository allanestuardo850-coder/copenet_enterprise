require "test_helper"

class ModuloSistemaTest < ActiveSupport::TestCase
  test "registrar_modulo_sistema crea o actualiza por codigo" do
    RegistrarModuloSistema.call(
      codigo: "MONEDAS",
      nombre: "Monedas",
      descripcion: "Catálogo de monedas",
      ruta: "/monedas",
      grupo: "Administración"
    )

    modulo = RegistrarModuloSistema.call(
      codigo: "MONEDAS",
      nombre: "Monedas del Sistema",
      descripcion: "Catálogo actualizado",
      ruta: "/monedas",
      grupo: "Administración"
    )

    assert_equal "Monedas del Sistema", modulo.nombre
    assert_equal 1, ModuloSistema.where(codigo: "MONEDAS").count
  end

  test "al crear un modulo sincroniza permisos base para roles existentes" do
    rol = Rol.create!(nombre: "Operaciones", activo: true)

    modulo = ModuloSistema.create!(
      codigo: "CLIENTES_TEST",
      nombre: "Clientes Test",
      descripcion: "Modulo de clientes para validar permisos",
      ruta: "/clientes_test",
      grupo: "Cobros",
      activo: true
    )

    permiso = rol.permisos.find_by(modulo_sistema: modulo)
    assert_not_nil permiso
  end
end
