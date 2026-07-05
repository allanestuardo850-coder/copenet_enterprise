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

ActiveRecord::Schema[8.1].define(version: 2026_07_05_133000) do
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
end
