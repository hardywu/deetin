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

ActiveRecord::Schema.define(version: 2019_01_15_160613) do

  create_table "markets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "base_unit", limit: 10, null: false
    t.string "quote_unit", limit: 10, null: false
    t.integer "base_precision", limit: 1, default: 8, null: false
    t.integer "quote_precision", limit: 1, default: 8, null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "state", null: false
    t.integer "member_id", null: false
    t.decimal "funds_received", precision: 32, scale: 16, default: "0.0"
    t.integer "trades_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "otc_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "member_id", null: false
    t.string "currency_id", limit: 10, null: false
    t.decimal "balance", precision: 32, scale: 16, default: "0.0", null: false
    t.decimal "locked", precision: 32, scale: 16, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trades", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.decimal "price", precision: 32, scale: 16, null: false
    t.decimal "volume", precision: 32, scale: 16, null: false
    t.integer "base", null: false
    t.integer "quote", null: false
    t.integer "trend", null: false
    t.string "market_id", limit: 20, null: false
    t.integer "ask_member_id", null: false
    t.integer "bid_member_id", null: false
    t.decimal "funds", precision: 32, scale: 16, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

end
