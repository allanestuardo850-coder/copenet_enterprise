class CreateAuditoriaPrecioCotizaciones < ActiveRecord::Migration[8.1]
  def change
    create_table :auditoria_precio_cotizaciones do |t|
      t.references :cotizacion, null: false, foreign_key: true
      t.references :cotizacion_detalle, null: false, foreign_key: true
      t.references :usuario, foreign_key: true
      t.decimal :original_price, precision: 14, scale: 2, null: false
      t.decimal :previous_applied_price, precision: 14, scale: 2
      t.decimal :new_applied_price, precision: 14, scale: 2, null: false
      t.text :reason
      t.string :price_rule_applied
      t.datetime :changed_at, null: false
      t.timestamps
    end
  end
end
