# == Schema Information
#
# Table name: currencies
#
#  id                    :string(8)        not null, primary key
#  name                  :string(255)
#  blockchain_key        :string(32)
#  symbol                :string(1)        not null
#  type                  :string(30)       default("coin"), not null
#  deposit_fee           :decimal(32, 16)  default(0.0)
#  min_deposit_amount    :decimal(32, 16)  default(0.0), not null
#  min_collection_amount :decimal(32, 16)  default(0.0), not null
#  withdraw_fee          :decimal(32, 16)  default(0.0), not null
#  min_withdraw_amount   :decimal(32, 16)  default(0.0), not null
#  withdraw_limit_24h    :decimal(32, 16)  default(0.0), not null
#  withdraw_limit_72h    :decimal(32, 16)  default(0.0), not null
#  position              :integer          default(0), not null
#  options               :string(1000)     default("{}"), not null
#  enabled               :boolean          default(TRUE), not null
#  base_factor           :integer          default(1), not null
#  precision             :integer          default(8), not null
#  icon_url              :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class Coin < Currency
end
