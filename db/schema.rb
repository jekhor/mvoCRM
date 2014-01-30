# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140130131259) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "donations", :force => true do |t|
    t.string   "document_number"
    t.integer  "amount"
    t.string   "donor"
    t.text     "note"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "payment_id",      :default => 0, :null => false
    t.datetime "datetime"
  end

  add_index "donations", ["payment_id"], :name => "index_donations_on_payment_id", :unique => true

  create_table "members", :force => true do |t|
    t.string   "given_names"
    t.string   "last_name"
    t.date     "date_of_birth"
    t.string   "address"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.boolean  "application_exists",      :default => false
    t.date     "join_date"
    t.string   "join_protocol"
    t.integer  "card_number"
    t.boolean  "joined"
    t.string   "postal_address"
    t.date     "application_date"
    t.string   "site_user"
    t.date     "site_user_creation_date"
  end

  add_index "members", ["email"], :name => "index_members_on_email", :unique => true
  add_index "members", ["site_user"], :name => "index_members_on_site_user", :unique => true

  create_table "payments", :force => true do |t|
    t.integer  "member_id"
    t.date     "date",                                        :null => false
    t.decimal  "amount",       :precision => 10, :scale => 2, :null => false
    t.date     "start_date",                                  :null => false
    t.date     "end_date",                                    :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.text     "note"
    t.string   "number"
    t.string   "user_account"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "var",                      :null => false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", :limit => 30
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], :name => "index_settings_on_thing_type_and_thing_id_and_var", :unique => true

end
