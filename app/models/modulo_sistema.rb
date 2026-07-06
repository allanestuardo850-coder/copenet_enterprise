class ModuloSistema < ApplicationRecord
  has_many :permisos, dependent: :destroy
  has_many :usuario_permisos, dependent: :destroy
  has_many :roles, through: :permisos

  validates :codigo, presence: true, uniqueness: true
  validates :nombre, presence: true

  after_commit :sincronizar_permisos_base, on: %i[create update]

  scope :activos, -> { where(activo: true) }
  scope :orden_admin, -> { order(Arel.sql("COALESCE(grupo, 'Sin grupo') ASC"), :nombre, :codigo) }

  private

  def sincronizar_permisos_base
    SincronizarPermisosModulo.call(self)
  end
end
