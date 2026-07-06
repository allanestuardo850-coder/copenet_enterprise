class AddCompanyToProductoServicios < ActiveRecord::Migration[8.1]
  def change
    add_reference :producto_servicios, :company, foreign_key: true
  end
end
