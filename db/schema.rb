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

ActiveRecord::Schema.define(version: 20170829141245) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cities_factors", force: :cascade do |t|
    t.bigint "city_id"
    t.bigint "factor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "score"
    t.index ["city_id"], name: "index_cities_factors_on_city_id"
    t.index ["factor_id"], name: "index_cities_factors_on_factor_id"
  end

  create_table "cities_indices", force: :cascade do |t|
    t.bigint "city_id"
    t.bigint "index_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "score"
    t.index ["city_id"], name: "index_cities_indices_on_city_id"
    t.index ["index_id"], name: "index_cities_indices_on_index_id"
  end

  create_table "factors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "indices", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "type"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_factors", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "factor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factor_id"], name: "index_users_factors_on_factor_id"
    t.index ["user_id"], name: "index_users_factors_on_user_id"
  end

  add_foreign_key "cities_factors", "cities"
  add_foreign_key "cities_factors", "factors"
  add_foreign_key "cities_indices", "cities"
  add_foreign_key "cities_indices", "indices"
  add_foreign_key "profiles", "users"
  add_foreign_key "users_factors", "factors"
  add_foreign_key "users_factors", "users"
end
