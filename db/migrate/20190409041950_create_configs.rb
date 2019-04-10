class CreateConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :configs, id: :string do |t|
      t.string :value
    end
  end
end
