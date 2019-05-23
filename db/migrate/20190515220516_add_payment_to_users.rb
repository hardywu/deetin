class AddPaymentToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.references :payment, polymorphic: true, index: true
      t.string :device_id
    end
  end
end
