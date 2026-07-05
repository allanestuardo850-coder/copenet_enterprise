class UsuarioRol < ApplicationRecord
  belongs_to :usuario
  belongs_to :rol

  validates :usuario, :rol, presence: true
  validates :rol_id, uniqueness: { scope: :usuario_id }
end
