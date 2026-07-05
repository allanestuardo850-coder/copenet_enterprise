require "test_helper"

class SesionesTest < ActionDispatch::IntegrationTest
  setup do
    @usuario = Usuario.create!(
      nombre: "Root",
      apellido: "Sistema",
      email: "root@test.com",
      password: "Admin123!",
      password_confirmation: "Admin123!",
      activo: true,
      root: true
    )
  end

  test "muestra login" do
    get login_path
    assert_response :success
  end

  test "redirige al login si no hay sesion" do
    get dashboard_path
    assert_redirected_to login_path
  end

  test "permite iniciar sesion" do
    post login_path, params: { email: @usuario.email, password: "Admin123!" }
    assert_redirected_to dashboard_path
  end
end
