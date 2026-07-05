# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_05_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "address"
    t.string "commercial_name"
    t.string "company_type"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "fel_scenario_code"
    t.string "fel_token"
    t.string "infile_key"
    t.string "infile_prefix"
    t.string "infile_signature_key"
    t.string "infile_signature_prefix"
    t.string "legal_name"
    t.string "notification_email"
    t.string "phone"
    t.string "status"
    t.string "tax_id"
    t.datetime "updated_at", null: false
    t.string "vat_affiliation"
    t.index ["commercial_name"], name: "index_companies_on_commercial_name"
    t.index ["legal_name"], name: "index_companies_on_legal_name"
    t.index ["tax_id"], name: "index_companies_on_tax_id"
  end

  create_table "modulo_sistemas", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.string "codigo", null: false
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.string "nombre", null: false
    t.string "ruta"
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_modulo_sistemas_on_codigo", unique: true
  end

  create_table "permisos", force: :cascade do |t|
    t.boolean "puede_configurar", default: false, null: false
    t.boolean "puede_crear", default: false, null: false
    t.boolean "puede_editar", default: false, null: false
    t.boolean "puede_eliminar", default: false, null: false
    t.boolean "puede_exportar", default: false, null: false
    t.boolean "puede_ver", default: false, null: false
    t.datetime "created_at", null: false
    t.bigint "modulo_sistema_id", null: false
    t.bigint "rol_id", null: false
    t.datetime "updated_at", null: false
    t.index ["modulo_sistema_id"], name: "index_permisos_on_modulo_sistema_id"
    t.index ["rol_id", "modulo_sistema_id"], name: "index_permisos_on_rol_id_and_modulo_sistema_id", unique: true
    t.index ["rol_id"], name: "index_permisos_on_rol_id"
  end

  create_table "roles", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.string "nombre", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_roles_on_nombre", unique: true
  end

  create_table "usuario_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "rol_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "usuario_id", null: false
    t.index ["rol_id"], name: "index_usuario_roles_on_rol_id"
    t.index ["usuario_id", "rol_id"], name: "index_usuario_roles_on_usuario_id_and_rol_id", unique: true
    t.index ["usuario_id"], name: "index_usuario_roles_on_usuario_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.string "apellido", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "nombre", null: false
    t.string "password_digest", null: false
    t.boolean "root", default: false, null: false
    t.datetime "ultimo_acceso_en"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_usuarios_on_email", unique: true
  end

  add_foreign_key "permisos", "modulo_sistemas"
  add_foreign_key "permisos", "roles"
  add_foreign_key "usuario_roles", "roles"
  add_foreign_key "usuario_roles", "usuarios"
end
