class AddCallbackToTrades < ActiveRecord::Migration[5.2]
  def change
    change_table :trades do |t|
      t.string :callback_url
      t.string :no
      t.index :no, unique: true
    end
  end
end
