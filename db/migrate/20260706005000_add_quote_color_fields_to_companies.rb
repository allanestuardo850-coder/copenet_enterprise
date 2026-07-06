class AddQuoteColorFieldsToCompanies < ActiveRecord::Migration[8.1]
  def change
    change_table :companies, bulk: true do |t|
      t.string :quote_table_header_color
      t.string :quote_contact_text_color
    end
  end
end
