class AddCotizacionFieldsToProductoServicios < ActiveRecord::Migration[8.1]
  def change
    add_column :producto_servicios, :problema_resuelve, :text
    add_column :producto_servicios, :caso_uso, :text
    add_column :producto_servicios, :incluye_cotizacion, :text
    add_column :producto_servicios, :requisitos_cierre_venta, :text
  end
end
