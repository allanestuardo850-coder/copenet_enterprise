class ModuloSistema < ApplicationRecord
  has_many :permisos, dependent: :destroy
  has_many :roles, through: :permisos

  validates :codigo, presence: true, uniqueness: true
  validates :nombre, presence: true

  scope :activos, -> { where(activo: true) }
end
