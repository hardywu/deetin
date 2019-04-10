class ChangeKeysOfUsers < ActiveRecord::Migration[5.2]
  def up
    change_column :users, :domain, :string, default: nil, null: true
    User.update_all domain: nil
    Member.all.each { |member| member.update domain: User.find(member.master_id).uid }
    Bot.all.each { |member| member.update domain: User.find(member.master_id).uid }
    remove_column :users, :master_id
  end

  def down
    add_column :users, :master_id, :bigint, index: true
    Member.all.each { |member| member.update master_id: User.find_by(uid: member.domain).id }
    Bot.all.each { |member| member.update master_id: User.find_by(uid: member.domain).id }
    User.update_all domain: 'nanyazq.com'
    change_column :users, :domain, :string, default: 'nanyazq.com', null: false
  end
end
