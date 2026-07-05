class Rol < ApplicationRecord
  has_many :usuario_roles, dependent: :destroy
  has_many :usuarios, through: :usuario_roles
  has_many :permisos, dependent: :destroy
  has_many :modulo_sistemas, through: :permisos

  validates :nombre, presence: true, uniqueness: true

  scope :activos, -> { where(activo: true) }
end
