class CreateLabels < ActiveRecord::Migration[5.2]
  def change
    create_table :labels do |t|
      t.bigint :user_id, null: false, unsigned: true
      t.string :key,     null: false
      t.string :value,   null: false
      t.string :scope,   default: "public", null: false
      t.timestamps
      t.index [:user_id]
      t.index [:user_id, :key, :scope]
    end
  end
end
