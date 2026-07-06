class CreateProductoServicios < ActiveRecord::Migration[8.1]
  def change
    create_table :producto_servicios do |t|
      t.string :codigo, null: false
      t.string :nombre, null: false
      t.string :nombre_corto
      t.text :descripcion
      t.boolean :activo, null: false, default: true
      t.date :fecha_inicio_vigencia
      t.date :fecha_fin_vigencia

      t.string :tipo_producto, null: false
      t.string :categoria, null: false
      t.string :subcategoria
      t.string :modelo_cobro, null: false
      t.string :estado_catalogo, null: false, default: "Borrador"

      t.references :moneda, foreign_key: true
      t.decimal :precio_base, precision: 14, scale: 2
      t.boolean :permite_descuento, null: false, default: false
      t.decimal :porcentaje_descuento_maximo, precision: 5, scale: 2
      t.boolean :requiere_aprobacion_comercial, null: false, default: false

      t.boolean :es_recurrente, null: false, default: false
      t.string :recurrencia
      t.integer :dia_cobro
      t.boolean :cobra_proporcional, null: false, default: false
      t.boolean :requiere_consumo, null: false, default: false
      t.string :unidad_cobro
      t.decimal :cantidad_minima, precision: 14, scale: 2
      t.decimal :cantidad_maxima, precision: 14, scale: 2

      t.boolean :facturable, null: false, default: true
      t.string :tipo_facturacion
      t.boolean :agrupable_en_factura, null: false, default: true
      t.boolean :requiere_descripcion_dinamica, null: false, default: false

      t.boolean :requiere_activacion, null: false, default: false
      t.boolean :requiere_soporte, null: false, default: false
      t.string :nivel_servicio
      t.boolean :permite_suspension, null: false, default: false

      t.boolean :requiere_contrato, null: false, default: false
      t.integer :duracion_minima_meses
      t.boolean :permite_renovacion, null: false, default: false

      t.boolean :liquidable, null: false, default: false
      t.string :modelo_liquidacion
      t.decimal :porcentaje_liquidacion, precision: 5, scale: 2
      t.string :base_liquidacion

      t.boolean :contabilizable, null: false, default: false
      t.string :cuenta_ingreso_codigo
      t.string :centro_costo_codigo

      t.boolean :visible_en_crm, null: false, default: true
      t.boolean :visible_en_contratos, null: false, default: true
      t.boolean :visible_en_expedientes, null: false, default: true
      t.integer :orden_visual

      t.boolean :afecto_iva, null: false, default: true
      t.string :tipo_impuesto
      t.boolean :requiere_fel_detallado, null: false, default: false

      t.decimal :costo_base, precision: 14, scale: 2
      t.decimal :margen_objetivo, precision: 5, scale: 2
      t.boolean :permite_costo_variable, null: false, default: false

      t.timestamps
    end

    add_index :producto_servicios, :codigo, unique: true
    add_index :producto_servicios, :nombre
    add_index :producto_servicios, :tipo_producto
    add_index :producto_servicios, :categoria
    add_index :producto_servicios, :modelo_cobro
    add_index :producto_servicios, :estado_catalogo
  end
end
