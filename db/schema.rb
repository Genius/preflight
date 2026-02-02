# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_06_203538) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applied_checklists", id: :serial, force: :cascade do |t|
    t.integer "checklist_id", null: false
    t.bigint "github_pull_request_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["checklist_id"], name: "index_applied_checklists_on_checklist_id"
    t.index ["github_pull_request_id", "checklist_id"], name: "one_checklist_application_per_pull", unique: true
  end

  create_table "checklist_items", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "checklist_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "created_by_id", null: false
  end

  create_table "checklists", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "created_by_id", null: false
    t.integer "github_repository_id", null: false
    t.string "with_file_matching_pattern"
    t.integer "last_updated_by_id", null: false
    t.index ["github_repository_id"], name: "index_checklists_on_github_repository_id"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "github_repositories", id: :serial, force: :cascade do |t|
    t.integer "github_id", null: false
    t.string "github_full_name", null: false
    t.string "github_owner_type", null: false
    t.string "github_url", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["github_id"], name: "index_github_repositories_on_github_id", unique: true
  end

  create_table "github_webhooks", id: :serial, force: :cascade do |t|
    t.integer "github_id", null: false
    t.integer "github_repository_id", null: false
    t.integer "created_by_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "hook_deleted_at", precision: nil
    t.index ["github_id"], name: "index_github_webhooks_on_github_id"
    t.index ["github_repository_id"], name: "index_github_webhooks_on_github_repository_id", unique: true
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.string "provider", null: false
    t.integer "user_id", null: false
    t.string "uid", null: false
    t.text "omniauth_data", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["uid", "provider"], name: "index_identities_on_uid_and_provider", unique: true
    t.index ["user_id", "provider"], name: "index_identities_on_user_id_and_provider", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "admin", default: false, null: false
    t.text "accessible_github_repository_ids", default: [], array: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end
