class PerfilController < ApplicationController
  skip_before_action :authorize_modulo!

  def show
    @current_page = :perfil
    @usuario = current_usuario
  end

  def update
    @current_page = :perfil
    @usuario = current_usuario
    attributes = perfil_params

    if password_incompleta?(attributes)
      @usuario.assign_attributes(attributes.except(:password, :password_confirmation))
      @usuario.errors.add(:password_confirmation, "debe completarse junto con la nueva contraseña")
      render :show, status: :unprocessable_entity
    elsif @usuario.update(attributes)
      redirect_to perfil_path, notice: "Perfil actualizado correctamente."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def perfil_params
    permitted = params.require(:usuario).permit(:fotografia, :password, :password_confirmation)
    if permitted[:password].blank? && permitted[:password_confirmation].blank?
      permitted.except(:password, :password_confirmation)
    else
      permitted
    end
  end

  def password_incompleta?(attributes)
    values = [attributes[:password], attributes[:password_confirmation]]
    values.any?(&:present?) && values.any?(&:blank?)
  end
end
