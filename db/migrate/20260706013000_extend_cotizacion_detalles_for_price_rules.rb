class ExtendCotizacionDetallesForPriceRules < ActiveRecord::Migration[8.1]
  def change
    add_column :cotizacion_detalles, :catalog_price, :decimal, precision: 14, scale: 2
    add_column :cotizacion_detalles, :applied_price, :decimal, precision: 14, scale: 2
    add_column :cotizacion_detalles, :internal_cost, :decimal, precision: 14, scale: 2
    add_column :cotizacion_detalles, :discount_amount, :decimal, precision: 14, scale: 2, null: false, default: 0
    add_column :cotizacion_detalles, :discount_reason, :text
    add_column :cotizacion_detalles, :price_rule_applied, :string
    add_column :cotizacion_detalles, :manual_price_override, :boolean, null: false, default: false
    add_column :cotizacion_detalles, :price_override_reason, :text
    add_column :cotizacion_detalles, :billing_authorized, :boolean, null: false, default: false

    add_index :cotizacion_detalles, :price_rule_applied
  end
end
