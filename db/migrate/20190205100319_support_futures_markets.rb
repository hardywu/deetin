class SupportFuturesMarkets < ActiveRecord::Migration[5.2]
  def up
    change_table :markets, bulk: true do |t|
      t.string :type
      t.string :code
      t.string :name
      t.index %i[code], unique: true
    end

    change_table :orders, bulk: true do |t|
      t.change :state, :integer, limit: 4, null: false, default: 0
      t.rename :member_id, :user_id
      t.string :ord_type, null: false, default: 'limit'
    end

    create_table :positions do |t|
      t.integer  'user_id', null: false
      t.integer  'market_id', null: false
      t.integer  'volume', default: 0, null: false
      t.decimal  'margin', precision: 32, scale: 16, default: 0.0, null: false
      t.decimal  'credit', precision: 32, scale: 16, default: 0.0, null: false
      t.timestamps
    end

    change_table :users, bulk: true do |t|
      t.string :username, unique: true, null: true
    end

    create_table :payments do |t|
      t.string :type
      t.string :name
      t.string :no
      t.text :desc
      t.belongs_to :user
      t.timestamps
      t.index %i[user_id type], unique: true
    end
  end

  def down
    change_table :orders, bulk: true do |t|
      t.change :state, :integer, limit: 4, null: false
      t.rename :user_id, :member_id
      t.remove :ord_type
    end

    change_table :markets, bulk: true do |t|
      t.remove_index %i[code]
      t.remove :type
      t.remove :code
      t.remove :name
    end

    drop_table :positions

    change_table :users, bulk: true do |t|
      t.remove :username
    end

    drop_table :payments
  end
end
