class ChangeKeysOfPayments < ActiveRecord::Migration[5.2]
  def change
    change_table :payments do |t|
      t.change :pubkey, :text
      t.change :secret, :text
    end
  end
end
