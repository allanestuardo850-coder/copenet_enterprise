class UsuariosController < ApplicationController
  before_action :set_usuario, only: %i[show edit update destroy]

  def index
    @current_page = :usuarios
    @usuarios = Usuario.includes(:roles).order(:nombre, :apellido)
  end

  def show
    @current_page = :usuarios
  end

  def new
    @current_page = :usuarios
    @usuario = Usuario.new(activo: true, root: false)
    cargar_roles
  end

  def create
    @current_page = :usuarios
    @usuario = Usuario.new(usuario_params)
    cargar_roles

    if @usuario.save
      sync_roles
      redirect_to @usuario, notice: "Usuario creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :usuarios
    cargar_roles
  end

  def update
    @current_page = :usuarios
    cargar_roles

    if @usuario.update(usuario_update_params)
      sync_roles
      redirect_to @usuario, notice: "Usuario actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @usuario.root? && Usuario.where(root: true).count <= 1
      redirect_to usuarios_path, alert: "No puedes eliminar el último usuario root."
      return
    end

    @usuario.destroy
    redirect_to usuarios_path, notice: "Usuario eliminado correctamente."
  end

  private

  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  def cargar_roles
    @roles = Rol.order(:nombre)
  end

  def sync_roles
    @usuario.rol_ids = params.dig(:usuario, :rol_ids).to_a.reject(&:blank?)
  end

  def usuario_params
    params.require(:usuario).permit(
      :nombre, :apellido, :email, :password, :password_confirmation, :activo, :root
    )
  end

  def usuario_update_params
    permitted = usuario_params
    if permitted[:password].blank? && permitted[:password_confirmation].blank?
      permitted.except(:password, :password_confirmation)
    else
      permitted
    end
  end
end
