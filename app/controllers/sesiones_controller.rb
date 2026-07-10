class SesionesController < ApplicationController
  layout "publico"

  skip_before_action :require_login
  skip_before_action :set_navigation
  skip_before_action :authorize_modulo!

  def new
    redirect_to ruta_segura_post_login if usuario_signed_in?
  end

  def create
    usuario = Usuario.activos.find_by(email: params[:email].to_s.downcase.strip)

    if usuario&.authenticate(params[:password].to_s)
      session[:usuario_id] = usuario.id
      usuario.update_column(:ultimo_acceso_en, Time.current)
      BitacoraEvento.registrar!(
        event_type: "acceso.login",
        description: "Inicio de sesión",
        subject: usuario,
        usuario: usuario,
        metadata: {
          module_code: "ACCESO",
          module_name: "Acceso y seguridad"
        }
      )
      destino = ruta_segura_post_login

      if destino == login_path && !usuario.root?
        reset_session
        flash.now[:alert] = "Tu usuario no tiene permisos asignados para ingresar."
        render :new, status: :unprocessable_entity
      else
        redirect_to destino, notice: "Sesión iniciada correctamente."
      end
    else
      flash.now[:alert] = "Correo o contraseña inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if current_usuario.present?
      BitacoraEvento.registrar!(
        event_type: "acceso.logout",
        description: "Cierre de sesión",
        subject: current_usuario,
        usuario: current_usuario,
        metadata: {
          module_code: "ACCESO",
          module_name: "Acceso y seguridad"
        }
      )
    end
    reset_session
    redirect_to login_path, notice: "Sesión cerrada correctamente."
  end
end
