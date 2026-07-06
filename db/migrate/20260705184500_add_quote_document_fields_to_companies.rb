class AddQuoteDocumentFieldsToCompanies < ActiveRecord::Migration[8.1]
  def change
    change_table :companies, bulk: true do |t|
      t.string :quote_title
      t.string :quote_subtitle
      t.text :quote_intro_text
      t.text :quote_closing_text
      t.string :quote_signature_name
      t.string :quote_signature_role
      t.text :quote_terms_text
    end
  end
end
