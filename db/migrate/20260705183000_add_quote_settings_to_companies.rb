class AddQuoteSettingsToCompanies < ActiveRecord::Migration[8.1]
  def change
    change_table :companies, bulk: true do |t|
      t.string :quote_contact_name
      t.string :quote_contact_role
      t.string :quote_contact_email
      t.string :quote_contact_phone
      t.string :quote_website_url
      t.string :quote_format_name
      t.text :quote_footer_note
    end
  end
end
