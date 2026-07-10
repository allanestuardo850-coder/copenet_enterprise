class Usuario < ApplicationRecord
  has_secure_password

  has_one_attached :fotografia

  has_many :usuario_roles, dependent: :destroy
  has_many :usuario_permisos, dependent: :destroy
  has_many :roles, through: :usuario_roles
  has_many :permisos, through: :roles

  validates :nombre, :apellido, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, on: :create

  before_validation :normalizar_email

  scope :activos, -> { where(activo: true) }

  def permisos_activos
    Permiso.joins(:rol, :modulo_sistema)
           .where(rol_id: rol_ids)
           .merge(Rol.activos)
           .merge(ModuloSistema.activos)
  end

  def permiso_directo_para(modulo_sistema)
    usuario_permisos.find_by(modulo_sistema_id: modulo_sistema.id)
  end

  def permiso_base_por_rol(modulo_sistema, accion)
    return true if root?

    permiso = permisos_activos.find_by(modulo_sistema_id: modulo_sistema.id)
    return false unless permiso

    permiso.public_send("puede_#{accion}?")
  end

  def nombre_completo
    [nombre, apellido].join(" ").strip
  end

  private

  def normalizar_email
    self.email = email.to_s.downcase.strip
  end
end
