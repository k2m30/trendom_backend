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

ActiveRecord::Schema.define(version: 20160330111258) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "profiles", force: true do |t|
    t.string   "name"
    t.string   "position"
    t.string   "photo"
    t.string   "location"
    t.string   "email"
    t.text     "notes"
    t.string   "linkedin_url"
    t.string   "twitter_url"
    t.string   "facebook_url"
    t.integer  "linkedin_id"
    t.integer  "twitter_id"
    t.integer  "facebook_id"
    t.integer  "emails_available"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "profile_id"
  end

  add_index "profiles_users", ["profile_id"], name: "index_profiles_users_on_profile_id", using: :btree
  add_index "profiles_users", ["user_id"], name: "index_profiles_users_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                default: "",  null: false
    t.string   "encrypted_password",   default: "",  null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "name"
    t.string   "image"
    t.string   "uid"
    t.string   "plan",                 default: ""
    t.datetime "subscription_expires"
    t.string   "calls_left",           default: "0"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
