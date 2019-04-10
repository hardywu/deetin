# == Schema Information
#
# Table name: accounts
#
#  id          :bigint(8)        not null, primary key
#  member_id   :integer          not null
#  currency_id :string(10)       not null
#  balance     :decimal(32, 16)  default(0.0), not null
#  locked      :decimal(32, 16)  default(0.0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class AccountSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :currency_id, :balance, :locked
end
