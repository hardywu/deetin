# == Schema Information
#
# Table name: payments
#
#  id            :bigint(8)        not null, primary key
#  type          :string(255)
#  name          :string(255)
#  no            :string(255)
#  desc          :text(65535)
#  user_id       :bigint(8)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  limit         :decimal(32, 2)   default(1000.0)
#  daily_limit   :decimal(32, 2)   default(50000.0)
#  monthly_limit :decimal(32, 2)   default(1550000.0)
#  appid         :string(255)
#  pubkey        :text(65535)
#  secret        :text(65535)
#

class UnionpaymentSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :name, :no, :desc, :type,
             :limit, :daily_limit, :monthly_limit
  has_one :user
end
