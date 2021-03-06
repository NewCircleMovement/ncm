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

ActiveRecord::Schema.define(version: 20180428115150) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_points", force: :cascade do |t|
    t.integer  "location_id"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "menu_item"
    t.string   "menu_title"
    t.text     "profile"
  end

  create_table "admissioncards", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "admission_id"
    t.integer  "charge_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "admissions", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "price"
    t.datetime "start_t"
    t.datetime "end_t"
    t.integer  "epicenter_id"
    t.integer  "n_max"
    t.integer  "n_actual",     default: 0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "calendars", force: :cascade do |t|
    t.time     "day_start"
    t.time     "day_end"
    t.float    "module_length"
    t.boolean  "flexible"
    t.string   "resource_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "epicenters", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "video_url"
    t.integer  "max_members",          default: 1000
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "growing",              default: false
    t.boolean  "manifested",           default: false
    t.integer  "location_id"
    t.integer  "niveau"
    t.integer  "depth_members"
    t.integer  "depth_fruits"
    t.integer  "mother_id"
    t.integer  "monthly_fruits_basis", default: 100
    t.string   "slug"
    t.string   "image"
    t.string   "tagline"
    t.string   "size"
    t.string   "meeting_day"
    t.time     "meeting_time"
    t.string   "meeting_week"
    t.string   "meeting_address"
    t.boolean  "meeting_active",       default: false
    t.boolean  "ongoing",              default: true
    t.string   "api_token"
    t.integer  "members_count"
    t.integer  "fruits_count"
    t.boolean  "show_postits",         default: false
  end

  create_table "epipages", force: :cascade do |t|
    t.string   "slug"
    t.string   "menu_title"
    t.string   "title"
    t.text     "body"
    t.string   "kind",         default: "Info"
    t.integer  "epicenter_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "event_logs", force: :cascade do |t|
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "acts_on_type"
    t.integer  "acts_on_id"
    t.string   "event_type"
    t.string   "description"
    t.json     "details"
    t.integer  "log_level"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "fruitbags", force: :cascade do |t|
    t.integer  "amount",         default: 0
    t.string   "fruittype_id"
    t.string   "fruitbasket_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "fruitbaskets", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fruittrees", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "fruits_per_month"
    t.integer  "fruittype_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "yield",            default: 0
  end

  create_table "fruittypes", force: :cascade do |t|
    t.string   "name"
    t.float    "monthly_decay"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "epicenter_id"
  end

  create_table "information", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "string"
    t.integer  "position"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "kind"
    t.string   "slug"
  end

  create_table "locations", force: :cascade do |t|
    t.integer  "density"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "loggings", force: :cascade do |t|
    t.integer  "id_1"
    t.integer  "id_2"
    t.string   "type_1"
    t.string   "type_2"
    t.string   "event"
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "membership_changes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "epicenter_id"
    t.integer  "old_membership_id"
    t.integer  "new_membership_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "membershipcards", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "membership_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "payment_id"
    t.integer  "epicenter_id"
    t.boolean  "valid_payment", default: true
    t.boolean  "valid_supply",  default: true
  end

  create_table "memberships", force: :cascade do |t|
    t.string   "name"
    t.integer  "monthly_fee"
    t.integer  "epicenter_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "engagement",   default: 2
    t.string   "payment_id"
    t.integer  "monthly_gain"
    t.text     "profile"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pg_search_documents", ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree

  create_table "postits", force: :cascade do |t|
    t.integer  "resource_id"
    t.integer  "epicenter_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "wall_id"
    t.integer  "visibility"
    t.integer  "asking",         default: 0
    t.boolean  "only_epicenter", default: false
    t.string   "title"
    t.text     "body"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "postits", ["only_epicenter"], name: "index_postits_on_only_epicenter", using: :btree
  add_index "postits", ["owner_id"], name: "index_postits_on_owner_id", using: :btree
  add_index "postits", ["owner_type"], name: "index_postits_on_owner_type", using: :btree
  add_index "postits", ["resource_id"], name: "index_postits_on_resource_id", using: :btree

  create_table "resource_requests", force: :cascade do |t|
    t.integer  "requester_id"
    t.integer  "holder_id"
    t.integer  "resource_id"
    t.integer  "postit_id"
    t.integer  "amount"
    t.boolean  "accepted"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "resource_requests", ["holder_id"], name: "index_resource_requests_on_holder_id", using: :btree
  add_index "resource_requests", ["postit_id"], name: "index_resource_requests_on_postit_id", using: :btree
  add_index "resource_requests", ["resource_id"], name: "index_resource_requests_on_resource_id", using: :btree

  create_table "resources", force: :cascade do |t|
    t.string   "type"
    t.boolean  "bookable"
    t.string   "title"
    t.text     "body"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "calender_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "holder_id"
    t.string   "image"
  end

  add_index "resources", ["holder_id"], name: "index_resources_on_holder_id", using: :btree
  add_index "resources", ["owner_id"], name: "index_resources_on_owner_id", using: :btree
  add_index "resources", ["owner_type"], name: "index_resources_on_owner_type", using: :btree

  create_table "resources_collections", force: :cascade do |t|
    t.integer  "epipage_id"
    t.integer  "resource_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "tshirts", force: :cascade do |t|
    t.integer  "epicenter_id"
    t.integer  "user_id"
    t.integer  "access_point_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "membership_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "image"
    t.text     "profile_text"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
