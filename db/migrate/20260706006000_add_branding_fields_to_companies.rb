class AddBrandingFieldsToCompanies < ActiveRecord::Migration[8.1]
  def change
    change_table :companies, bulk: true do |t|
      t.string :web
      t.string :correo_comercial
      t.string :color_primario
      t.string :color_secundario
      t.string :color_acento
    end
  end
end
