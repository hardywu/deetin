class CreateLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :levels do |t|
      t.string :key, null: false
      t.string :value
      t.string :description

      t.timestamps
    end
  end
end
