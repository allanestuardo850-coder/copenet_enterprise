class UsuarioPermiso < ApplicationRecord
  belongs_to :usuario
  belongs_to :modulo_sistema

  validates :usuario, :modulo_sistema, presence: true
  validates :modulo_sistema_id, uniqueness: { scope: :usuario_id }
end
