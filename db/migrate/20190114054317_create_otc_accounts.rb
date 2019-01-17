class CreateOtcAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :otc_accounts do |t|
      t.integer  'member_id',   limit: 4, null: false
      t.string   'currency_id', limit: 10, null: false
      t.decimal  'balance', precision: 32, scale: 16, default: 0.0, null: false
      t.decimal  'locked', precision: 32, scale: 16, default: 0.0, null: false
      t.timestamps
    end
  end
end
