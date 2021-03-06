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

ActiveRecord::Schema.define(version: 20160318221515) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pharmacists", force: :cascade do |t|
    t.string "rpps_id",         null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email_address"
    t.string "siret"
    t.string "siren"
    t.string "finess"
    t.string "finess_judicial"
  end

  add_index "pharmacists", ["rpps_id"], name: "index_pharmacists_on_rpps_id", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string "number"
  end

end
