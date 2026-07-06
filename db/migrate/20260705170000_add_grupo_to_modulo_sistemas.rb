class AddGrupoToModuloSistemas < ActiveRecord::Migration[8.1]
  def change
    add_column :modulo_sistemas, :grupo, :string
    add_index :modulo_sistemas, :grupo
  end
end
