class CreateCotizaciones < ActiveRecord::Migration[8.1]
  def change
    create_table :cotizaciones do |t|
      t.references :producto_servicio, null: false, foreign_key: true
      t.string :codigo, null: false
      t.string :cliente, null: false
      t.string :contacto, null: false
      t.string :correo, null: false
      t.string :telefono
      t.integer :vigencia_dias, null: false, default: 15
      t.decimal :precio_base, precision: 14, scale: 2, null: false
      t.decimal :porcentaje_descuento, precision: 5, scale: 2
      t.decimal :monto_descuento, precision: 14, scale: 2, null: false, default: 0
      t.decimal :precio_final, precision: 14, scale: 2, null: false, default: 0
      t.text :alcance_personalizado
      t.text :observaciones
      t.string :estado, null: false, default: "Generada"
      t.timestamps
    end

    add_index :cotizaciones, :codigo, unique: true
    add_index :cotizaciones, :created_at
  end
end
