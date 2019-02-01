class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.bigint    :user_id, null: false, unsigned: true
      t.string    :upload
      t.string    :doc_type
      t.string    :doc_number
      t.date      :doc_expire
      t.text      :metadata
      t.timestamps
      t.index [:user_id]

      t.timestamps
    end
  end
end
