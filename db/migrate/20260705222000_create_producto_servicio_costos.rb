class CreateProductoServicioCostos < ActiveRecord::Migration[8.1]
  def change
    create_table :producto_servicio_costos do |t|
      t.references :producto_servicio, null: false, foreign_key: true
      t.string :tipo_costo, null: false
      t.string :nombre, null: false
      t.text :descripcion
      t.decimal :monto, precision: 14, scale: 2, null: false
      t.string :recurrencia, null: false
      t.integer :orden, null: false, default: 0
      t.boolean :activo, null: false, default: true

      t.timestamps
    end

    add_index :producto_servicio_costos, :tipo_costo
    add_index :producto_servicio_costos, :activo
  end
end
