class CreateBitacoraEventos < ActiveRecord::Migration[8.1]
  def change
    create_table :bitacora_eventos do |t|
      t.string :event_type, null: false
      t.text :description, null: false
      t.references :subject, polymorphic: true
      t.references :usuario, foreign_key: true
      t.references :cliente, foreign_key: true
      t.references :cotizacion, foreign_key: true
      t.references :proyecto, foreign_key: true
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :bitacora_eventos, :event_type
  end
end
