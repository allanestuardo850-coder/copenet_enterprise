class FacturasController < ApplicationController
  before_action :set_factura, only: %i[show edit update certificar_infile]
  before_action :load_catalogs, only: %i[new create edit update]

  def index
    @current_page = :facturas
    @filters = { query: params[:query].to_s.strip, status: params[:status].to_s.strip }
    @facturas = apply_filters(Factura.includes(:cliente, :moneda).ordenadas)
    paginate_facturas
  end

  def show
    @current_page = :facturas
  end

  def new
    @current_page = :facturas
    @factura = Factura.new(fecha_emision: Date.current, estado: "borrador", activo: true, company: Company.activas.first)
  end

  def create
    @current_page = :facturas
    @factura = Factura.new(factura_params)

    if @factura.save
      redirect_to facturas_path, notice: "Factura guardada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_page = :facturas
  end

  def update
    @current_page = :facturas

    if @factura.update(factura_params)
      redirect_to facturas_path, notice: "Factura actualizada correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def certificar_infile
    resultado = @factura.certificar_infile!
    if resultado[:resultado]
      redirect_to factura_path(@factura), notice: "DTE certificado correctamente con INFILE."
    else
      redirect_to factura_path(@factura), alert: resultado[:mensaje].presence || "No se pudo certificar el DTE con INFILE."
    end
  end

  private

  def set_factura
    @factura = Factura.find(params[:id])
  end

  def load_catalogs
    @clientes = Cliente.ordenados
    @monedas = Moneda.activas.order(:nombre)
    @companies = Company.activas.order(:commercial_name, :legal_name)
  end

  def factura_params
    params.require(:factura).permit(:numero, :serie, :cliente_id, :cliente_nombre, :fecha_emision, :fecha_vencimiento, :total, :moneda_id, :company_id, :estado, :notas, :activo)
  end

  def apply_filters(scope)
    if @filters[:query].present?
      term = "%#{@filters[:query]}%"
      scope = scope.where("numero ILIKE :term OR serie ILIKE :term OR cliente_nombre ILIKE :term", term: term)
    end
    scope = scope.where(estado: @filters[:status]) if @filters[:status].present?
    scope
  end

  def paginate_facturas
    @facturas_total_count = @facturas.count
    @facturas_per_page = per_page
    @facturas_total_pages = [(@facturas_total_count.to_f / @facturas_per_page).ceil, 1].max
    @facturas_page = [[params[:page].to_i, 1].max, @facturas_total_pages].min
    @facturas = @facturas.offset((@facturas_page - 1) * @facturas_per_page).limit(@facturas_per_page)
  end

  def per_page
    allowed = [10, 20, 50, 100]
    value = params[:per_page].to_i
    allowed.include?(value) ? value : 10
  end
end
