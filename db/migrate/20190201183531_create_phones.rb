class CreatePhones < ActiveRecord::Migration[5.2]
  def change
    create_table :phones do |t|
      t.integer :user_id, null: false, unsigned: true
      t.string :country, null: false
      t.string :number,  null: false
      t.string :code,    limit: 5
      t.datetime :validated_at
      t.timestamps
      t.index [:user_id]
      t.index [:number]

      t.timestamps
    end
  end
end
