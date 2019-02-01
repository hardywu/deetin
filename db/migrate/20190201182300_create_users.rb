class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string    :uid,                 null: false
      t.string    :domain,              null: false, default: "nanyazq.com"
      t.string    :email,               null: false
      t.string    :password_digest,     null: false
      t.string    :role,                null: false, default: "member"
      t.integer   :level,               null: false, default: 0
      t.string    :state,               null: false, default: "pending"
      t.boolean   :otp,                 default: false
      t.integer   :referral_id

      t.timestamps
      t.index ["domain", "email"], name: "index_users_on_email", unique: true
      t.index ["uid"], name: "index_users_on_uid", unique: true
    end
  end
end
