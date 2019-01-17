class CreateMarkets < ActiveRecord::Migration[5.2]
  def change
    create_table :markets do |t|
	    t.string   "base_unit",        limit: 10,                                        null: false
	    t.string   "quote_unit",       limit: 10,                                        null: false
	    t.integer  "base_precision",   limit: 1,                          default: 8,    null: false
	    t.integer  "quote_precision",  limit: 1,                          default: 8,    null: false
	    t.boolean  "enabled",                                             default: true, null: false

      t.timestamps
    end
  end
end
