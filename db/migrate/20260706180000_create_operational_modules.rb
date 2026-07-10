class CreateOperationalModules < ActiveRecord::Migration[8.1]
  def change
    create_table :costos do |t|
      t.string :concepto, null: false
      t.string :centro_costo
      t.string :clasificacion
      t.string :periodo
      t.date :fecha
      t.decimal :monto, precision: 14, scale: 2, default: 0, null: false
      t.references :moneda, foreign_key: true
      t.string :estado, default: "registrado", null: false
      t.string :proveedor
      t.text :descripcion
      t.boolean :activo, default: true, null: false
      t.timestamps
    end

    add_index :costos, :concepto
    add_index :costos, :estado
    add_index :costos, :periodo

    create_table :cobros do |t|
      t.string :referencia, null: false
      t.references :cliente, foreign_key: true
      t.string :cliente_nombre, null: false
      t.string :gestor
      t.date :fecha_vencimiento
      t.date :fecha_pago
      t.decimal :monto, precision: 14, scale: 2, default: 0, null: false
      t.references :moneda, foreign_key: true
      t.string :estado, default: "en_gestion", null: false
      t.text :notas
      t.boolean :activo, default: true, null: false
      t.timestamps
    end

    add_index :cobros, :referencia, unique: true
    add_index :cobros, :cliente_nombre
    add_index :cobros, :estado
    add_index :cobros, :fecha_vencimiento

    create_table :facturas do |t|
      t.string :numero, null: false
      t.string :serie
      t.references :cliente, foreign_key: true
      t.string :cliente_nombre, null: false
      t.date :fecha_emision
      t.date :fecha_vencimiento
      t.decimal :total, precision: 14, scale: 2, default: 0, null: false
      t.references :moneda, foreign_key: true
      t.string :estado, default: "borrador", null: false
      t.text :notas
      t.boolean :activo, default: true, null: false
      t.timestamps
    end

    add_index :facturas, :numero, unique: true
    add_index :facturas, :cliente_nombre
    add_index :facturas, :estado
    add_index :facturas, :fecha_emision

    create_table :contratos do |t|
      t.string :codigo, null: false
      t.references :cliente, foreign_key: true
      t.string :cliente_nombre, null: false
      t.string :tipo_contrato
      t.date :fecha_inicio
      t.date :fecha_fin
      t.decimal :valor, precision: 14, scale: 2, default: 0, null: false
      t.references :moneda, foreign_key: true
      t.string :estado, default: "borrador", null: false
      t.string :responsable
      t.text :notas
      t.boolean :activo, default: true, null: false
      t.timestamps
    end

    add_index :contratos, :codigo, unique: true
    add_index :contratos, :cliente_nombre
    add_index :contratos, :estado
    add_index :contratos, :fecha_fin
  end
end
