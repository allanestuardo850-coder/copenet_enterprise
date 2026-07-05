# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Company.find_or_initialize_by(tax_id: "103480861").tap do |company|
  company.commercial_name = "Copenet"
  company.legal_name = "Copenet, S.A."
  company.company_type = "Tecnología y Servicios"
  company.email = "info@copenet.com.gt"
  company.phone = "+502 2222-0000"
  company.address = "Ciudad de Guatemala, Guatemala"
  company.status = "Activa"
  company.active = true
  company.infile_prefix = "MCECSAPRO"
  company.infile_key = "65A948AB99814B245BD110CAB64E0FE7"
  company.infile_signature_prefix = "MCECSAPRO"
  company.infile_signature_key = "e8d3c14007fb41c9b927af7340dbe8a0"
  company.vat_affiliation = "GEN"
  company.fel_token = "cf99bd377f53f1116bf4c4fd15ebcb18"
  company.fel_scenario_code = "2"
  company.notification_email = "notificaciones@copenet.com.gt"
  company.save!
end
