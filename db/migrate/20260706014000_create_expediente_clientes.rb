class CreateExpedienteClientes < ActiveRecord::Migration[8.1]
  def change
    create_table :expediente_clientes do |t|
      t.references :cliente, null: false, foreign_key: true
      t.string :titulo, null: false
      t.string :estado, null: false, default: "activo"
      t.text :resumen
      t.timestamps
    end
  end
end
