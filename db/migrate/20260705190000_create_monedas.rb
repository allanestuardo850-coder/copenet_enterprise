class CreateMonedas < ActiveRecord::Migration[8.1]
  def change
    create_table :monedas do |t|
      t.integer :codigo, null: false
      t.string :nombre, null: false
      t.string :simbolo, null: false
      t.boolean :activo, null: false, default: true

      t.timestamps
    end

    add_index :monedas, :codigo, unique: true
    add_index :monedas, :nombre, unique: true
  end
end
