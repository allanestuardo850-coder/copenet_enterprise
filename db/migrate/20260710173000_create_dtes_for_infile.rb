class CreateDtesForInfile < ActiveRecord::Migration[8.1]
  def change
    add_reference :facturas, :company, foreign_key: true unless column_exists?(:facturas, :company_id)

    create_table :dtes do |t|
      t.references :factura, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.string :certificador, null: false, default: "infile"
      t.string :tipo_dte, null: false, default: "FACT"
      t.string :estado, null: false, default: "pendiente_certificar"
      t.string :identificador, null: false
      t.string :uuid
      t.string :serie
      t.string :numero
      t.string :nit_receptor, null: false, default: "CF"
      t.string :nombre_receptor, null: false, default: "Consumidor Final"
      t.string :correo_receptor
      t.string :tipo_especial
      t.string :moneda, null: false, default: "GTQ"
      t.text :descripcion, null: false
      t.decimal :monto, precision: 14, scale: 2, null: false, default: 0
      t.datetime :fecha_certificacion
      t.text :xml_sin_firmar
      t.text :xml_firmado
      t.jsonb :errores_fel, null: false, default: {}
      t.jsonb :request_payload, null: false, default: {}
      t.jsonb :response_payload, null: false, default: {}
      t.timestamps

      t.index :identificador, unique: true
      t.index :estado
      t.index :uuid
    end
  end
end
