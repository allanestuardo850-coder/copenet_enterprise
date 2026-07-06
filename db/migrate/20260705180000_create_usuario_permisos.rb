class CreateUsuarioPermisos < ActiveRecord::Migration[8.1]
  def change
    create_table :usuario_permisos do |t|
      t.references :usuario, null: false, foreign_key: true
      t.references :modulo_sistema, null: false, foreign_key: true
      t.boolean :puede_ver, null: false, default: false
      t.boolean :puede_crear, null: false, default: false
      t.boolean :puede_editar, null: false, default: false
      t.boolean :puede_eliminar, null: false, default: false
      t.boolean :puede_exportar, null: false, default: false
      t.boolean :puede_configurar, null: false, default: false

      t.timestamps
    end

    add_index :usuario_permisos, %i[usuario_id modulo_sistema_id], unique: true
  end
end
