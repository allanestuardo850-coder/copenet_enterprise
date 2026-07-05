class SesionesController < ApplicationController
  layout "publico"

  skip_before_action :require_login
  skip_before_action :set_navigation
  skip_before_action :authorize_modulo!

  def new
    redirect_to dashboard_path if usuario_signed_in?
  end

  def create
    usuario = Usuario.activos.find_by(email: params[:email].to_s.downcase.strip)

    if usuario&.authenticate(params[:password].to_s)
      session[:usuario_id] = usuario.id
      usuario.update_column(:ultimo_acceso_en, Time.current)
      redirect_to dashboard_path, notice: "Sesión iniciada correctamente."
    else
      flash.now[:alert] = "Correo o contraseña inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Sesión cerrada correctamente."
  end
end
