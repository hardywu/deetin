class CreateTrades < ActiveRecord::Migration[5.2]
  def change
    create_table :trades do |t|
      t.decimal 'price',         precision: 32, scale: 16, null: false
      t.decimal 'volume',        precision: 32, scale: 16, null: false
      t.integer 'base',          limit: 4,                 null: false
      t.integer 'quote',         limit: 4,                 null: false
      t.integer 'trend',         limit: 4,                 null: false
      t.string  'market_id',     limit: 20,                null: false
      t.integer 'ask_member_id', limit: 4,                 null: false
      t.integer 'bid_member_id', limit: 4,                 null: false
      t.decimal 'funds',         precision: 32, scale: 16, null: false

      t.timestamps
    end
  end
end
