class AddKeysToPayments < ActiveRecord::Migration[5.2]
  def change
    change_table :payments do |t|
      t.decimal :limit, default: 1_000, scale: 2, precision: 32
      t.decimal :daily_limit, default: 50_000, scale: 2, precision: 32
      t.decimal :monthly_limit, default: 1550_000, scale: 2, precision: 32
      t.string :appid
      t.string :pubkey
      t.string :secret
    end

    change_table :users do |t|
      t.boolean :enabled, default: false, null: false
      t.string :secret
      t.index %i[enabled]
    end
  end
end
