# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_08_14_112550) do

  create_table "admins", force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "donations", force: :cascade do |t|
    t.string "document_number", limit: 255
    t.integer "amount"
    t.string "donor", limit: 255
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payment_id", default: 0, null: false
    t.datetime "datetime"
    t.index ["payment_id"], name: "index_donations_on_payment_id", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.string "given_names", limit: 255
    t.string "last_name", limit: 255
    t.date "date_of_birth"
    t.string "address", limit: 255
    t.string "email", limit: 255
    t.string "phone", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "join_date"
    t.integer "card_number"
    t.string "postal_address", limit: 255
    t.string "site_user", limit: 255
    t.date "site_user_creation_date"
    t.boolean "membership_paused"
    t.text "membership_pause_note"
    t.index ["email"], name: "index_members_on_email", unique: true
    t.index ["site_user"], name: "index_members_on_site_user", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.integer "member_id"
    t.date "date", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "note"
    t.string "number", limit: 255
    t.string "user_account", limit: 255
    t.string "payment_type", limit: 255
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", limit: 255, null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", limit: 255, null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

end
