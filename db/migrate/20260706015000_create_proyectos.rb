class CreateProyectos < ActiveRecord::Migration[8.1]
  def change
    create_table :proyectos do |t|
      t.references :cliente, null: false, foreign_key: true
      t.references :cotizacion, null: false, foreign_key: true
      t.references :expediente_cliente, null: false, foreign_key: true
      t.string :nombre, null: false
      t.string :estado, null: false, default: "pendiente_inicio"
      t.date :fecha_inicio
      t.decimal :monto_aprobado, precision: 14, scale: 2
      t.decimal :monto_facturable, precision: 14, scale: 2
      t.decimal :costo_interno_estimado, precision: 14, scale: 2
      t.decimal :margen_estimado, precision: 14, scale: 2
      t.text :checklist_asignable
      t.text :documentacion_relacionada
      t.timestamps
    end

    add_index :proyectos, :estado
  end
end
