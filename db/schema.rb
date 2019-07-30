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

ActiveRecord::Schema.define(version: 2019_07_29_155124) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "utm_term"
    t.string "utm_content"
  end

  create_table "college_courses", force: :cascade do |t|
    t.string "name"
    t.string "podio_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "podio_item_id"
    t.integer "gv_podio_id"
    t.integer "ge_podio_id"
    t.integer "gt_podio_id"
    t.bigint "expa_id"
  end

  create_table "english_levels", force: :cascade do |t|
    t.integer "english_level"
    t.string "englishable_type"
    t.integer "englishable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exchange_participants", force: :cascade do |t|
    t.string "fullname"
    t.string "cellphone"
    t.string "email"
    t.date "birthdate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "registerable_id"
    t.string "registerable_type"
    t.bigint "local_committee_id"
    t.bigint "college_course_id"
    t.bigint "university_id"
    t.string "password"
    t.boolean "cellphone_contactable", default: false
    t.integer "scholarity"
    t.integer "campaign_id"
    t.string "other_university"
    t.integer "expa_id"
    t.integer "podio_id"
    t.integer "exchange_type", default: 0
    t.integer "status"
    t.integer "approved_sync_count", default: 1
    t.text "academic_backgrounds", array: true
    t.integer "referral_type"
    t.datetime "deleted_at"
    t.string "city"
    t.integer "exchange_reason"
    t.string "department"
    t.boolean "rdstation_opportunity", default: false
    t.integer "rdstation_lifecycle_stage", default: 0
    t.string "rdstation_uuid"
    t.datetime "updated_at_expa"
    t.index ["college_course_id"], name: "index_exchange_participants_on_college_course_id"
    t.index ["local_committee_id"], name: "index_exchange_participants_on_local_committee_id"
    t.index ["registerable_type", "registerable_id"], name: "registerable_index_on_exchange_participants"
    t.index ["university_id"], name: "index_exchange_participants_on_university_id"
  end

  create_table "expa_applications", force: :cascade do |t|
    t.integer "expa_id"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "exchange_participant_id"
    t.datetime "updated_at_expa"
    t.integer "expa_ep_id"
    t.string "opportunity_name"
    t.bigint "home_lc_id"
    t.bigint "host_lc_id"
    t.integer "sdg_target_index"
    t.integer "sdg_goal_index"
    t.datetime "podio_last_sync"
    t.datetime "applied_at"
    t.datetime "accepted_at"
    t.datetime "approved_at"
    t.datetime "break_approved_at"
    t.integer "product"
    t.integer "podio_id"
    t.integer "tnid"
    t.bigint "home_mc_id"
    t.boolean "podio_sent", default: false
    t.datetime "podio_sent_at"
    t.boolean "has_error", default: false
    t.text "academic_backgrounds", array: true
    t.jsonb "standards"
    t.integer "prep_podio_id"
    t.datetime "realized_at"
    t.datetime "completed_at"
    t.boolean "prep_podio_sync_error", default: false
    t.boolean "from_impact", default: false
    t.datetime "opportunity_date"
    t.datetime "opportunity_start_date"
    t.boolean "resync", default: false
    t.index ["home_lc_id"], name: "index_expa_applications_on_home_lc_id"
    t.index ["home_mc_id"], name: "index_expa_applications_on_home_mc_id"
    t.index ["host_lc_id"], name: "index_expa_applications_on_host_lc_id"
  end

  create_table "experiences", force: :cascade do |t|
    t.boolean "language", default: false
    t.boolean "marketing", default: false
    t.boolean "information_technology", default: false
    t.boolean "management", default: false
    t.bigint "gt_participant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gt_participant_id"], name: "index_experiences_on_gt_participant_id"
  end

  create_table "ge_participants", force: :cascade do |t|
    t.integer "spanish_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "when_can_travel"
    t.integer "preferred_destination"
    t.integer "work_experience"
  end

  create_table "gt_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "preferred_destination"
    t.integer "when_can_travel"
    t.integer "work_experience"
  end

  create_table "gv_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "when_can_travel"
  end

  create_table "impact_brazil_referrals", force: :cascade do |t|
    t.bigint "ep_expa_id"
    t.bigint "application_expa_id"
    t.bigint "opportunity_expa_id"
    t.datetime "application_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "local_committee_segmentations", force: :cascade do |t|
    t.bigint "origin_local_committee_id"
    t.bigint "destination_local_committee_id"
    t.integer "program"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "local_committees", force: :cascade do |t|
    t.string "name"
    t.integer "expa_id"
    t.integer "podio_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.integer "member_committee_id"
  end

  create_table "member_committees", force: :cascade do |t|
    t.string "name"
    t.integer "expa_id"
    t.integer "podio_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "survey_histories", force: :cascade do |t|
    t.integer "podio_id"
    t.jsonb "surveys"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "surveys", force: :cascade do |t|
    t.string "collector"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "sync_params", force: :cascade do |t|
    t.datetime "podio_application_status_last_sync"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "universities", force: :cascade do |t|
    t.string "name"
    t.string "podio_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "podio_item_id"
    t.bigint "local_committee_id"
    t.string "city"
    t.string "department"
    t.bigint "expa_id"
    t.index ["local_committee_id"], name: "index_universities_on_local_committee_id"
  end

  create_table "university_local_committees", force: :cascade do |t|
    t.bigint "university_id"
    t.bigint "local_committee_id"
    t.integer "program"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["local_committee_id"], name: "index_university_local_committees_on_local_committee_id"
    t.index ["program"], name: "index_university_local_committees_on_program"
    t.index ["university_id"], name: "index_university_local_committees_on_university_id"
  end

  add_foreign_key "exchange_participants", "college_courses"
  add_foreign_key "exchange_participants", "local_committees"
  add_foreign_key "exchange_participants", "universities"
  add_foreign_key "expa_applications", "local_committees", column: "home_lc_id"
  add_foreign_key "expa_applications", "local_committees", column: "host_lc_id"
  add_foreign_key "expa_applications", "member_committees", column: "home_mc_id"
  add_foreign_key "universities", "local_committees"
  add_foreign_key "university_local_committees", "local_committees"
  add_foreign_key "university_local_committees", "universities"
end
