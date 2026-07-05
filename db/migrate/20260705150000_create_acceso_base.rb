class CreateAccesoBase < ActiveRecord::Migration[8.1]
  def change
    create_table :usuarios do |t|
      t.string :nombre, null: false
      t.string :apellido, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :activo, null: false, default: true
      t.boolean :root, null: false, default: false
      t.datetime :ultimo_acceso_en

      t.timestamps
    end
    add_index :usuarios, :email, unique: true

    create_table :roles do |t|
      t.string :nombre, null: false
      t.text :descripcion
      t.boolean :activo, null: false, default: true

      t.timestamps
    end
    add_index :roles, :nombre, unique: true

    create_table :usuario_roles do |t|
      t.references :usuario, null: false, foreign_key: true
      t.references :rol, null: false, foreign_key: true

      t.timestamps
    end
    add_index :usuario_roles, %i[usuario_id rol_id], unique: true

    create_table :modulo_sistemas do |t|
      t.string :codigo, null: false
      t.string :nombre, null: false
      t.text :descripcion
      t.string :ruta
      t.boolean :activo, null: false, default: true

      t.timestamps
    end
    add_index :modulo_sistemas, :codigo, unique: true

    create_table :permisos do |t|
      t.references :rol, null: false, foreign_key: true
      t.references :modulo_sistema, null: false, foreign_key: true
      t.boolean :puede_ver, null: false, default: false
      t.boolean :puede_crear, null: false, default: false
      t.boolean :puede_editar, null: false, default: false
      t.boolean :puede_eliminar, null: false, default: false
      t.boolean :puede_exportar, null: false, default: false
      t.boolean :puede_configurar, null: false, default: false

      t.timestamps
    end
    add_index :permisos, %i[rol_id modulo_sistema_id], unique: true
  end
end
