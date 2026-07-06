class CreateConfiguracionSistemas < ActiveRecord::Migration[8.1]
  def change
    create_table :configuracion_sistemas do |t|
      t.string :nombre_plataforma, null: false, default: "Copenet Enterprise"
      t.string :nombre_principal, null: false, default: "COPENET"
      t.string :nombre_secundario, null: false, default: "ENTERPRISE"
      t.string :login_eyebrow, null: false, default: "Copenet Enterprise"
      t.string :login_titulo, null: false, default: "Control empresarial con una base moderna y segura"
      t.text :login_subtitulo, null: false, default: "Plataforma empresarial para administración, costos, cobros y control operativo."
      t.string :promo_titulo, null: false, default: "Mejora tu experiencia"
      t.text :promo_descripcion, null: false, default: "Descubre todas las funcionalidades avanzadas de Copenet Enterprise."
      t.string :promo_boton_texto, null: false, default: "Ver planes"
      t.string :promo_boton_url, null: false, default: "#"
      t.string :footer_logo_texto, null: false, default: "VISA"
      t.string :footer_logo_etiqueta, null: false, default: "Visa"
      t.string :color_primario, null: false, default: "#2458e6"
      t.string :color_secundario, null: false, default: "#0b2d66"
      t.string :color_acento, null: false, default: "#6eb8ff"
      t.string :color_sidebar_desde, null: false, default: "#0a2146"
      t.string :color_sidebar_hasta, null: false, default: "#08172e"
      t.string :color_boton_texto, null: false, default: "#ffffff"

      t.timestamps
    end
  end
end
