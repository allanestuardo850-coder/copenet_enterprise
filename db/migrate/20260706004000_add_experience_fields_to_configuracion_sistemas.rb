class AddExperienceFieldsToConfiguracionSistemas < ActiveRecord::Migration[8.1]
  def change
    change_table :configuracion_sistemas, bulk: true do |t|
      t.string :placeholder_busqueda, null: false, default: "Buscar empresas, cuentas o reportes"
      t.string :loader_mensaje, null: false, default: "Cargando plataforma..."
      t.string :pdf_titulo, null: false, default: "Propuesta Comercial Autorizable"
      t.string :pdf_subtitulo, null: false, default: "Documento comercial generado desde el catálogo maestro del servicio."
      t.text :pdf_intro_texto, null: false, default: "Agradecemos el interés mostrado en nuestros productos y servicios. Por medio del presente documento compartimos una propuesta comercial estructurada a partir del catálogo maestro del servicio, separando cargos iniciales, mensuales, recurrentes y complementarios cuando aplique."
      t.text :pdf_cierre_texto, null: false, default: "Quedamos a su disposición para ampliar cualquier punto de esta propuesta, validar alcances finales y preparar la activación comercial correspondiente. Una vez autorizada, esta cotización puede continuar su preparación hacia el flujo de facturación."
      t.string :pdf_firma_nombre, null: false, default: "Equipo Comercial Copenet"
      t.string :pdf_firma_cargo, null: false, default: "Dirección Comercial"
    end
  end
end
