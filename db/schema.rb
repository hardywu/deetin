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

ActiveRecord::Schema.define(version: 2019_05_15_220516) do

  create_table "accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "member_id", null: false
    t.string "currency_id", limit: 10, null: false
    t.decimal "balance", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "locked", precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id", "member_id"], name: "index_accounts_on_currency_id_and_member_id", unique: true
    t.index ["member_id"], name: "index_accounts_on_member_id"
  end

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "configs", id: :string, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "value"
  end

  create_table "currencies", id: :string, limit: 8, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "blockchain_key", limit: 32
    t.string "symbol", limit: 1, null: false
    t.string "type", limit: 30, default: "coin", null: false
    t.decimal "deposit_fee", precision: 32, scale: 16, default: "0.0"
    t.decimal "min_deposit_amount", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "min_collection_amount", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "withdraw_fee", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "min_withdraw_amount", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "withdraw_limit_24h", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "withdraw_limit_72h", precision: 32, scale: 16, default: "0.0", null: false
    t.integer "position", default: 0, null: false
    t.string "options", limit: 1000, default: "{}", null: false
    t.boolean "enabled", default: true, null: false
    t.integer "base_factor", default: 1, null: false
    t.integer "precision", default: 8, null: false
    t.string "icon_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.string "upload"
    t.string "doc_type"
    t.string "doc_number"
    t.date "doc_expire"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "labels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id", null: false, unsigned: true
    t.string "key", null: false
    t.string "value", null: false
    t.string "scope", default: "public", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "key", "scope"], name: "index_labels_on_user_id_and_key_and_scope"
    t.index ["user_id"], name: "index_labels_on_user_id"
  end

  create_table "levels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "markets", id: :string, limit: 20, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "base_precision", limit: 1, default: 8, null: false
    t.integer "quote_precision", limit: 1, default: 8, null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "name"
    t.integer "position", default: 0, null: false
  end

  create_table "orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "type", limit: 8, null: false
    t.string "base", limit: 10, null: false
    t.string "quote", limit: 10, null: false
    t.string "market_id", limit: 20, null: false
    t.decimal "price", precision: 32, scale: 16
    t.decimal "volume", precision: 32, scale: 16, null: false
    t.decimal "origin_volume", precision: 32, scale: 16, null: false
    t.decimal "fee", precision: 32, scale: 16, default: "0.0", null: false
    t.integer "state", default: 0, null: false
    t.integer "user_id", null: false
    t.decimal "funds_received", precision: 32, scale: 16, default: "0.0"
    t.integer "trades_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ord_type", default: "limit", null: false
  end

  create_table "payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "no"
    t.text "desc"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "limit", precision: 32, scale: 2, default: "1000.0"
    t.decimal "daily_limit", precision: 32, scale: 2, default: "50000.0"
    t.decimal "monthly_limit", precision: 32, scale: 2, default: "1550000.0"
    t.string "appid"
    t.text "pubkey"
    t.text "secret"
    t.index ["user_id", "type"], name: "index_payments_on_user_id_and_type", unique: true
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "phones", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false, unsigned: true
    t.string "country", null: false
    t.string "number", null: false
    t.string "code", limit: 5
    t.datetime "validated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_phones_on_number"
    t.index ["user_id"], name: "index_phones_on_user_id"
  end

  create_table "positions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "market_id", null: false
    t.integer "volume", default: 0, null: false
    t.decimal "margin", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "credit", precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.string "first_name"
    t.string "last_name"
    t.date "dob"
    t.string "address"
    t.string "postcode"
    t.string "city"
    t.string "country"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "trades", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.decimal "price", precision: 32, scale: 16, null: false
    t.decimal "volume", precision: 32, scale: 16, null: false
    t.integer "trend", null: false
    t.string "market_id", limit: 20, null: false
    t.integer "ask_member_id", null: false
    t.integer "bid_member_id", null: false
    t.decimal "funds", precision: 32, scale: 16, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "master_id"
    t.integer "state", default: 0
    t.bigint "ask_id", null: false
    t.bigint "bid_id", null: false
    t.string "callback_url"
    t.string "no"
    t.index ["ask_id"], name: "index_trades_on_ask_id"
    t.index ["ask_member_id", "bid_member_id"], name: "index_trades_on_ask_member_id_and_bid_member_id"
    t.index ["bid_id"], name: "index_trades_on_bid_id"
    t.index ["created_at"], name: "index_trades_on_created_at"
    t.index ["market_id", "created_at"], name: "index_trades_on_market_id_and_created_at"
    t.index ["master_id"], name: "index_trades_on_master_id"
    t.index ["no"], name: "index_trades_on_no", unique: true
  end

  create_table "transfers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.string "currency_id", limit: 10, null: false
    t.decimal "amount", precision: 32, scale: 16, default: "0.0", null: false
    t.integer "state", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_transfers_on_currency_id"
    t.index ["member_id"], name: "index_transfers_on_member_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uid", null: false
    t.string "domain"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "member", null: false
    t.integer "level", default: 0, null: false
    t.string "state", default: "pending", null: false
    t.boolean "otp", default: false
    t.integer "referral_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "type"
    t.boolean "enabled", default: false, null: false
    t.string "secret"
    t.string "payment_type"
    t.bigint "payment_id"
    t.string "device_id"
    t.index ["domain", "email"], name: "index_users_on_email", unique: true
    t.index ["enabled"], name: "index_users_on_enabled"
    t.index ["payment_type", "payment_id"], name: "index_users_on_payment_type_and_payment_id"
    t.index ["uid"], name: "index_users_on_uid", unique: true
    t.index ["username"], name: "index_users_on_username"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
