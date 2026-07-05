class Usuario < ApplicationRecord
  has_secure_password

  has_many :usuario_roles, dependent: :destroy
  has_many :roles, through: :usuario_roles
  has_many :permisos, through: :roles

  validates :nombre, :apellido, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, on: :create

  before_validation :normalizar_email

  scope :activos, -> { where(activo: true) }

  def permisos_activos
    Permiso.joins(:rol, :modulo_sistema)
           .where(rol_id: role_ids)
           .merge(Rol.activos)
           .merge(ModuloSistema.activos)
  end

  private

  def normalizar_email
    self.email = email.to_s.downcase.strip
  end
end
