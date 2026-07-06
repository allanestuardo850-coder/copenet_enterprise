class CreateCotizacionDetalles < ActiveRecord::Migration[8.1]
  def change
    create_table :cotizacion_detalles do |t|
      t.references :cotizacion, null: false, foreign_key: true
      t.string :descripcion, null: false
      t.decimal :precio, precision: 14, scale: 2, null: false
      t.integer :orden, null: false, default: 0

      t.timestamps
    end

    add_index :cotizacion_detalles, :orden
  end
end
