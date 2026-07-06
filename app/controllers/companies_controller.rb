class CompaniesController < ApplicationController
  before_action :set_company, only: %i[show edit update configuration]

  def index
    @current_page = :companies
    @page_title = "Empresas"
    @page_description = nil
    @filters = {
      query: params[:query].to_s.strip,
      status: params[:status].to_s.strip,
      certification: params[:certification].to_s.strip
    }

    @companies = Company.order(:commercial_name, :legal_name)
    @companies = apply_filters(@companies)
  end

  def show
    @current_page = :companies
  end

  def new
    @current_page = :companies
    @company = Company.new(active: true, status: "Activa")
  end

  def create
    @current_page = :companies
    @company = Company.new(company_params)

    if @company.save
      redirect_to @company, notice: "Empresa creada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :companies
  end

  def update
    @current_page = :companies

    if @company.update(company_params)
      redirect_to @company, notice: "Empresa actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def configuration
    @current_page = :companies
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(
      :commercial_name,
      :legal_name,
      :tax_id,
      :company_type,
      :email,
      :phone,
      :web,
      :correo_comercial,
      :address,
      :status,
      :active,
      :color_primario,
      :color_secundario,
      :color_acento,
      :infile_prefix,
      :infile_key,
      :infile_signature_prefix,
      :infile_signature_key,
      :vat_affiliation,
      :fel_token,
      :fel_scenario_code,
      :notification_email,
      :quote_contact_name,
      :quote_contact_role,
      :quote_contact_email,
      :quote_contact_phone,
      :quote_website_url,
      :quote_format_name,
      :quote_title,
      :quote_subtitle,
      :quote_intro_text,
      :quote_closing_text,
      :quote_signature_name,
      :quote_signature_role,
      :quote_terms_text,
      :quote_table_header_color,
      :quote_contact_text_color,
      :quote_footer_note,
      :logo,
      :quote_logo,
      :remove_logo,
      :remove_quote_logo
    )
  end

  def apply_filters(scope)
    scope = scope.where(
      "commercial_name ILIKE :term OR legal_name ILIKE :term OR tax_id ILIKE :term OR email ILIKE :term",
      term: "%#{@filters[:query]}%"
    ) if @filters[:query].present?

    scope = case @filters[:status]
            when "active" then scope.where(active: true)
            when "inactive" then scope.where(active: false)
            when "draft" then scope.where(status: "Borrador")
            else scope
            end

    scope = case @filters[:certification]
            when "configured"
              scope.where.not(fel_token: [nil, ""]).where.not(infile_prefix: [nil, ""])
            when "pending"
              scope.where("fel_token IS NULL OR fel_token = '' OR infile_prefix IS NULL OR infile_prefix = ''")
            else scope
            end

    scope
  end
end
