class EnsureCompaniesTable < ActiveRecord::Migration[8.1]
  def change
    if table_exists?(:companias)
      rename_table :companias, :companies

      rename_column_if_exists :companies, :nombre_comercial, :commercial_name
      rename_column_if_exists :companies, :razon_social, :legal_name
      rename_column_if_exists :companies, :nit, :tax_id
      rename_column_if_exists :companies, :tipo_compania, :company_type
      rename_column_if_exists :companies, :correo_electronico, :email
      rename_column_if_exists :companies, :telefono, :phone
      rename_column_if_exists :companies, :direccion, :address
      rename_column_if_exists :companies, :estado, :status
      rename_column_if_exists :companies, :activa, :active
      rename_column_if_exists :companies, :prefijo_infile, :infile_prefix
      rename_column_if_exists :companies, :llave_infile, :infile_key
      rename_column_if_exists :companies, :prefijo_firma, :infile_signature_prefix
      rename_column_if_exists :companies, :llave_firma, :infile_signature_key
      rename_column_if_exists :companies, :afiliacion_iva, :vat_affiliation
      rename_column_if_exists :companies, :token_fel, :fel_token
      rename_column_if_exists :companies, :codigo_escenario_fel, :fel_scenario_code
      rename_column_if_exists :companies, :correo_electronico_notificaciones, :notification_email

      rename_index_if_exists :companies, "index_companias_on_nombre_comercial", "index_companies_on_commercial_name"
      rename_index_if_exists :companies, "index_companias_on_razon_social", "index_companies_on_legal_name"
      rename_index_if_exists :companies, "index_companias_on_nit", "index_companies_on_tax_id"
    elsif !table_exists?(:companies)
      create_table :companies do |t|
        t.string :commercial_name
        t.string :legal_name
        t.string :tax_id
        t.string :company_type
        t.string :email
        t.string :phone
        t.text :address
        t.string :status
        t.boolean :active, null: false, default: true
        t.string :infile_prefix
        t.string :infile_key
        t.string :infile_signature_prefix
        t.string :infile_signature_key
        t.string :vat_affiliation
        t.string :fel_token
        t.string :fel_scenario_code
        t.string :notification_email

        t.timestamps
      end

      add_index :companies, :commercial_name
      add_index :companies, :legal_name
      add_index :companies, :tax_id
    end
  end

  private

  def rename_column_if_exists(table_name, old_name, new_name)
    return unless column_exists?(table_name, old_name)
    return if column_exists?(table_name, new_name)

    rename_column table_name, old_name, new_name
  end

  def rename_index_if_exists(table_name, old_name, new_name)
    return unless index_name_exists?(table_name, old_name)
    return if index_name_exists?(table_name, new_name)

    rename_index table_name, old_name, new_name
  end
end
