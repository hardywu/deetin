class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string  'type',             limit: 8,  null: false
      t.string  'base',             limit: 10, null: false
      t.string  'quote',            limit: 10, null: false
      t.string  'market_id',        limit: 20, null: false
      t.decimal 'price',            precision: 32, scale: 16
      t.decimal 'volume',           precision: 32, scale: 16, null: false
      t.decimal 'origin_volume',    precision: 32, scale: 16, null: false
      t.decimal 'fee', null: false, precision: 32, scale: 16, default: 0.0
      t.integer 'state',            limit: 4, null: false
      t.integer 'member_id',        limit: 4, null: false
      t.decimal 'funds_received',   precision: 32, scale: 16, default: 0.0
      t.integer 'trades_count',     limit: 4, default: 0, null: false

      t.timestamps
    end
  end
end
