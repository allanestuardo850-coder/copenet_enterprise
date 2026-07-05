class Permiso < ApplicationRecord
  belongs_to :rol
  belongs_to :modulo_sistema

  validates :rol, :modulo_sistema, presence: true
  validates :modulo_sistema_id, uniqueness: { scope: :rol_id }
end
