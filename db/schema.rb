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

ActiveRecord::Schema.define(version: 20131118015551) do

  create_table "people", force: true do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
    t.string  "phone"
    t.string  "twitter"
    t.integer "registration_id"
  end

  create_table "races", force: true do |t|
    t.string   "name"
    t.datetime "race_datetime"
    t.datetime "registration_open"
    t.datetime "registration_close"
    t.integer  "max_teams"
    t.integer  "people_per_team"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrations", force: true do |t|
    t.string  "name"
    t.string  "description"
    t.string  "twitter"
    t.integer "team_id"
    t.integer "race_id"
  end

  add_index "registrations", ["team_id", "race_id"], name: "index_registrations_on_team_id_and_race_id", unique: true

  create_table "teams", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams_users", id: false, force: true do |t|
    t.integer "team_id"
    t.integer "user_id"
  end

end
