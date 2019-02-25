# == Schema Information
#
# Table name: transfers
#
#  id          :bigint(8)        not null, primary key
#  member_id   :bigint(8)        not null
#  currency_id :string(10)       not null
#  amount      :decimal(32, 16)  default(0.0), not null
#  state       :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Transfer < ApplicationRecord
end
