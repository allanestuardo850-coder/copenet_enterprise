class NormalizeProductoServicioCodigos < ActiveRecord::Migration[8.1]
  class ProductoServicioMigration < ApplicationRecord
    self.table_name = "producto_servicios"
  end

  def up
    ProductoServicioMigration.order(:created_at, :id).group_by { |registro| (registro.created_at || Time.current).year }.each_value do |registros|
      registros.each_with_index do |registro, index|
        year = (registro.created_at || Time.current).year
        registro.update_columns(
          codigo: format("CO-%<correlativo>05d-%<year>d", correlativo: index + 1, year: year)
        )
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "No es posible restaurar los códigos anteriores automáticamente."
  end
end
