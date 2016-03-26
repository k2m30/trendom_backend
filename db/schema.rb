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

ActiveRecord::Schema.define(version: 20151209113235) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "people", force: true do |t|
    t.string   "name"
    t.string   "position"
    t.string   "industry"
    t.string   "location"
    t.string   "email"
    t.text     "notes"
    t.string   "linkedin_url"
    t.string   "twitter_url"
    t.string   "facebook_url"
    t.integer  "linkedin_id"
    t.integer  "twitter_id"
    t.integer  "facebook_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people_users", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "people_id"
  end

  add_index "people_users", ["people_id"], name: "index_people_users_on_people_id", using: :btree
  add_index "people_users", ["user_id"], name: "index_people_users_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "oauth"
    t.string   "email"
    t.string   "name"
    t.string   "plan"
    t.datetime "subscription_expires"
    t.string   "calls_left"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
