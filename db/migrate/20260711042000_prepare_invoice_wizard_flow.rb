class PrepareInvoiceWizardFlow < ActiveRecord::Migration[8.1]
  def change
    add_column :clientes, :tax_id, :string
    add_column :clientes, :billing_name, :string
    add_column :clientes, :billing_address, :text

    add_index :clientes, :tax_id

    change_column_null :facturas, :numero, true

    create_table :factura_detalles do |t|
      t.references :factura, null: false, foreign_key: true
      t.references :producto_servicio, foreign_key: true
      t.references :producto_servicio_precio, foreign_key: true
      t.string :descripcion, null: false
      t.decimal :cantidad, precision: 14, scale: 2, default: 1, null: false
      t.decimal :precio_unitario, precision: 14, scale: 2, default: 0, null: false
      t.decimal :subtotal, precision: 14, scale: 2, default: 0, null: false
      t.decimal :total, precision: 14, scale: 2, default: 0, null: false
      t.boolean :afecto_iva, default: true, null: false

      t.timestamps
    end

    add_index :factura_detalles, :descripcion
  end
end
