class CreateProductoServicioPrecios < ActiveRecord::Migration[8.1]
  def change
    create_table :producto_servicio_precios do |t|
      t.references :producto_servicio, null: false, foreign_key: true
      t.string :nombre, null: false
      t.text :descripcion
      t.decimal :precio, precision: 14, scale: 2, null: false
      t.decimal :margen, precision: 5, scale: 2
      t.integer :orden, null: false, default: 0
      t.boolean :activo, null: false, default: true

      t.timestamps
    end

    add_index :producto_servicio_precios, :activo
    add_index :producto_servicio_precios, :orden
  end
end
