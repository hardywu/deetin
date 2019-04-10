class ChangeMarketsPrimaryKey < ActiveRecord::Migration[5.2]
  def up
    change_table :markets, bulk: true do |t|
      t.integer :position, default: 0, null: false
      t.remove :id, :base_unit, :quote_unit
      t.change :code, :string, limit: 20, primary_key: true
      t.remove_index name: 'index_markets_on_code'
    end
    rename_column :markets, :code, :id
  end

  def down
    change_table :markets do |t|
      t.remove :position
      t.string :base_unit, limit: 10, null: false
      t.string :quote_unit, limit: 10, null: false
      t.string :code
    end
    Market.update_all "code=id"
    Market.update_all "base_unit=SUBSTRING_INDEX(id, '/', 1)"
    Market.update_all "quote_unit=SUBSTRING_INDEX(id, '/', -1)"
    add_index :markets, %i[code], unique: true
    remove_column :markets, :id
    add_column :markets, :id, :bigint, primary_key: true
  end
end
