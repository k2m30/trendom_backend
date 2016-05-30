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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160530093644) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lists", force: :cascade do |t|
    t.string   "name"
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lists_profiles", id: false, force: :cascade do |t|
    t.integer "list_id",    null: false
    t.integer "profile_id", null: false
  end

  add_index "lists_profiles", ["list_id"], name: "index_lists_profiles_on_list_id", using: :btree
  add_index "lists_profiles", ["profile_id"], name: "index_lists_profiles_on_profile_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "position",         limit: 255
    t.string   "photo",            limit: 255
    t.string   "location",         limit: 255
    t.string   "emails",           limit: 255, default: "--- []\n"
    t.text     "notes"
    t.string   "linkedin_url",     limit: 255
    t.string   "twitter_url",      limit: 255
    t.string   "facebook_url",     limit: 255
    t.integer  "linkedin_id"
    t.integer  "twitter_id"
    t.integer  "facebook_id"
    t.integer  "emails_available"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                limit: 255, default: "",         null: false
    t.string   "encrypted_password",   limit: 255, default: "",         null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,          null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "name",                 limit: 255
    t.string   "image",                limit: 255
    t.string   "uid",                  limit: 255
    t.string   "plan",                 limit: 255, default: ""
    t.datetime "subscription_expires"
    t.string   "card_holder_name",     limit: 255
    t.string   "street_address",       limit: 255
    t.string   "street_address2",      limit: 255
    t.string   "city",                 limit: 255
    t.string   "state",                limit: 255
    t.string   "zip",                  limit: 255
    t.string   "country",              limit: 255
    t.string   "billing_email",        limit: 255
    t.string   "phone",                limit: 255
    t.string   "card_number",          limit: 255
    t.integer  "calls_left",                       default: 0
    t.float    "progress",                         default: 0.0
    t.text     "revealed_ids",                     default: "--- []\n"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
