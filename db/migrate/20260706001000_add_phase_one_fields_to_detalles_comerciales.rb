class AddPhaseOneFieldsToDetallesComerciales < ActiveRecord::Migration[8.1]
  class ProductoServicio < ActiveRecord::Base
    self.table_name = "producto_servicios"
  end

  class ProductoServicioPrecio < ActiveRecord::Base
    self.table_name = "producto_servicio_precios"
  end

  class ProductoServicioCosto < ActiveRecord::Base
    self.table_name = "producto_servicio_costos"
  end

  class CotizacionDetalle < ActiveRecord::Base
    self.table_name = "cotizacion_detalles"
  end

  def up
    add_reference :producto_servicio_precios, :moneda, foreign_key: { to_table: :monedas }
    add_column :producto_servicio_precios, :recurrencia, :string
    add_column :producto_servicio_precios, :seccion_cotizacion, :string
    add_column :producto_servicio_precios, :cotizable, :boolean, null: false, default: true
    add_column :producto_servicio_precios, :facturable, :boolean, null: false, default: true

    add_reference :producto_servicio_costos, :moneda, foreign_key: { to_table: :monedas }

    add_reference :cotizacion_detalles, :moneda, foreign_key: { to_table: :monedas }
    add_reference :cotizacion_detalles, :producto_servicio_precio, foreign_key: true
    add_column :cotizacion_detalles, :recurrencia, :string
    add_column :cotizacion_detalles, :seccion_cotizacion, :string
    add_column :cotizacion_detalles, :facturable, :boolean, null: false, default: true

    say_with_time "Backfilling monetary and commercial detail fields" do
      ProductoServicioPrecio.reset_column_information
      ProductoServicioCosto.reset_column_information
      CotizacionDetalle.reset_column_information

      ProductoServicio.find_each do |producto_servicio|
        recurrencia_base = producto_servicio.es_recurrente? ? (producto_servicio.recurrencia.presence || "Mensual") : "Unico"
        seccion_base = producto_servicio.es_recurrente? ? "Cargo mensual" : "Cargo inicial"

        ProductoServicioPrecio.where(producto_servicio_id: producto_servicio.id).find_each do |precio|
          precio.update_columns(
            moneda_id: precio.moneda_id.presence || producto_servicio.moneda_id,
            recurrencia: precio.recurrencia.presence || recurrencia_base,
            seccion_cotizacion: precio.seccion_cotizacion.presence || seccion_base
          )
        end

        ProductoServicioCosto.where(producto_servicio_id: producto_servicio.id).find_each do |costo|
          costo.update_columns(moneda_id: costo.moneda_id.presence || producto_servicio.moneda_id)
        end
      end

      CotizacionDetalle.find_each do |detalle|
        next unless detalle.respond_to?(:cotizacion_id)

        cotizacion = execute("SELECT producto_servicio_id FROM cotizaciones WHERE id = #{detalle.cotizacion_id}").first
        producto_servicio_id = cotizacion&.fetch("producto_servicio_id", nil)
        producto_servicio = producto_servicio_id.present? ? ProductoServicio.find_by(id: producto_servicio_id) : nil

        detalle.update_columns(
          moneda_id: detalle.moneda_id.presence || producto_servicio&.moneda_id,
          recurrencia: detalle.recurrencia.presence || (producto_servicio&.es_recurrente? ? (producto_servicio&.recurrencia.presence || "Mensual") : "Unico"),
          seccion_cotizacion: detalle.seccion_cotizacion.presence || (producto_servicio&.es_recurrente? ? "Cargo mensual" : "Cargo inicial")
        )
      end
    end
  end

  def down
    remove_column :cotizacion_detalles, :facturable
    remove_column :cotizacion_detalles, :seccion_cotizacion
    remove_column :cotizacion_detalles, :recurrencia
    remove_reference :cotizacion_detalles, :producto_servicio_precio, foreign_key: true
    remove_reference :cotizacion_detalles, :moneda, foreign_key: { to_table: :monedas }

    remove_reference :producto_servicio_costos, :moneda, foreign_key: { to_table: :monedas }

    remove_column :producto_servicio_precios, :facturable
    remove_column :producto_servicio_precios, :cotizable
    remove_column :producto_servicio_precios, :seccion_cotizacion
    remove_column :producto_servicio_precios, :recurrencia
    remove_reference :producto_servicio_precios, :moneda, foreign_key: { to_table: :monedas }
  end
end
