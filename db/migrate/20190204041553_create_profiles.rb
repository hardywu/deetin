class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.bigint    :user_id
      t.string    :first_name
      t.string    :last_name
      t.date      :dob
      t.string    :address
      t.string    :postcode
      t.string    :city
      t.string    :country
      t.text      :metadata
      t.timestamps
      t.index [:user_id]
    end
  end
end
