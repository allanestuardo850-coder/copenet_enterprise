class CreateClientes < ActiveRecord::Migration[8.1]
  def change
    create_table :clientes do |t|
      t.string :nombre, null: false
      t.string :contacto_principal
      t.string :email
      t.string :telefono
      t.string :client_type, null: false, default: "no_socio"
      t.boolean :is_copenet_client, null: false, default: false
      t.boolean :activo, null: false, default: true
      t.text :notas
      t.timestamps
    end

    add_index :clientes, :nombre
    add_index :clientes, :client_type
    add_index :clientes, :is_copenet_client
  end
end
