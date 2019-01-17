class CreateTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :transfers do |t|
      t.belongs_to :member, null: false, unique: false
      t.string :currency_id, limit: 10, null: false, index: true
      t.decimal :amount, precision: 32, scale: 16, default: 0.0, null: false
      t.integer :state, null: false, default: 0

      t.timestamps
    end
  end
end
