class ExtendProductoServiciosForCopenetRules < ActiveRecord::Migration[8.1]
  def change
    add_column :producto_servicios, :product_type, :string
    add_column :producto_servicios, :is_development, :boolean, null: false, default: false
    add_column :producto_servicios, :is_implementation, :boolean, null: false, default: false
    add_column :producto_servicios, :is_license, :boolean, null: false, default: false
    add_column :producto_servicios, :is_recurring_service, :boolean, null: false, default: false
    add_column :producto_servicios, :allow_discount, :boolean, null: false, default: false
    add_column :producto_servicios, :billable, :boolean, null: false, default: true
    add_column :producto_servicios, :visible_in_quote, :boolean, null: false, default: true
    add_column :producto_servicios, :no_charge_for_copenet, :boolean, null: false, default: false

    add_index :producto_servicios, :product_type
    add_index :producto_servicios, :no_charge_for_copenet
  end
end
