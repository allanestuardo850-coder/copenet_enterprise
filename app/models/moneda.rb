class Moneda < ApplicationRecord
  validates :codigo, presence: true, uniqueness: true, numericality: { only_integer: true }
  validates :nombre, :simbolo, presence: true
  validates :nombre, uniqueness: true

  scope :activas, -> { where(activo: true) }
end
