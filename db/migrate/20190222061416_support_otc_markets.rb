class SupportOtcMarkets < ActiveRecord::Migration[5.2]
  def up
     create_table :currencies, id: :string, limit: 8 do |t|
      t.string   :name
      t.string   :blockchain_key,        limit: 32
      t.string   :symbol,                limit: 1, null: false
      t.string   :type,                  limit: 30, default: 'coin', null: false
      t.decimal  :deposit_fee,           precision: 32, scale: 16, default: 0.0
      t.decimal  :min_deposit_amount,    precision: 32, scale: 16, default: 0.0, null: false
      t.decimal  :min_collection_amount, precision: 32, scale: 16, default: 0.0, null: false
      t.decimal  :withdraw_fee,          precision: 32, scale: 16, default: 0.0, null: false
      t.decimal  :min_withdraw_amount,   precision: 32, scale: 16, default: 0.0, null: false
      t.decimal  :withdraw_limit_24h,    precision: 32, scale: 16, default: 0.0, null: false
      t.decimal  :withdraw_limit_72h,    precision: 32, scale: 16, default: 0.0, null: false
      t.integer  :position,              default: 0,      null: false
      t.string   :options,               limit: 1000, default: '{}', null: false
      t.boolean  :enabled,               default: true, null: false
      t.integer  :base_factor,           default: 1, null: false
      t.integer  :precision,             default: 8, null: false
      t.string   :icon_url
      t.timestamps
    end

    rename_table :otc_accounts, :accounts
    add_index :accounts, %i[currency_id member_id], unique: true
    add_index :accounts, %i[member_id]
    add_index :users, %i[username]
    change_table :users do |t|
      t.belongs_to :master
      t.string :type
    end

    change_table :trades do |t|
      t.belongs_to :master
      t.integer :state, default: 0
      t.remove :base
      t.remove :quote
      t.belongs_to :ask, null: false
      t.belongs_to :bid, null: false
      t.index %i[created_at]
      t.index %i[ask_member_id bid_member_id]
      t.index %i[market_id created_at]
    end
  end

  def down
    drop_table :currencies
    remove_index :accounts, %i[currency_id member_id]
    remove_index :accounts, %i[member_id]
    remove_index :users, %i[username]
    rename_table :accounts, :otc_accounts
    change_table :users do |t|
      t.remove :master_id
      t.remove :type
    end
    change_table :trades do |t|
      t.remove :master_id
      t.remove :state
      t.remove :ask_id
      t.remove :bid_id
      t.integer 'base',          limit: 4,                 null: false
      t.integer 'quote',         limit: 4,                 null: false
      t.remove_index %i[created_at]
      t.remove_index %i[ask_member_id bid_member_id]
      t.remove_index %i[market_id created_at]
    end
  end
end
