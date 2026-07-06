require "test_helper"

class ClienteTest < ActiveSupport::TestCase
  test "cliente copenet sincroniza la bandera y crea expediente" do
    cliente = Cliente.create!(
      nombre: "Cliente CopeNET",
      client_type: "copenet",
      email: "cliente.copenet@example.com"
    )

    assert cliente.is_copenet_client?
    assert_not_nil cliente.expediente_cliente
  end
end
