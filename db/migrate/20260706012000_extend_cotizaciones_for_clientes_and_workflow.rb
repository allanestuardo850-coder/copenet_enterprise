class ExtendCotizacionesForClientesAndWorkflow < ActiveRecord::Migration[8.1]
  def change
    add_reference :cotizaciones, :cliente, foreign_key: true
    add_column :cotizaciones, :approved_at, :datetime
    add_column :cotizaciones, :signed_at, :datetime
    add_column :cotizaciones, :signed_by, :string
    add_column :cotizaciones, :cancellation_reason, :text
    add_column :cotizaciones, :version, :integer, null: false, default: 1
    add_column :cotizaciones, :workflow_notes, :text

    change_column_default :cotizaciones, :estado, from: "Generada", to: "borrador"
    add_index :cotizaciones, :estado
  end
end
