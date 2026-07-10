require "application_system_test_case"

class LoginTest < ApplicationSystemTestCase
  test "muestra la pantalla de inicio de sesion" do
    visit login_path

    assert_text "Iniciar Sesión"
  end
end
