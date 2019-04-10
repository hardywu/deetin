# == Schema Information
#
# Table name: trades
#
#  id            :bigint(8)        not null, primary key
#  price         :decimal(32, 16)  not null
#  volume        :decimal(32, 16)  not null
#  trend         :integer          not null
#  market_id     :string(20)       not null
#  ask_member_id :integer          not null
#  bid_member_id :integer          not null
#  funds         :decimal(32, 16)  not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  master_id     :bigint(8)
#  state         :integer          default("done")
#  ask_id        :bigint(8)        not null
#  bid_id        :bigint(8)        not null
#  callback_url  :string(255)
#  no            :string(255)
#

class TradeSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :price, :volume, :market_id, :state, :funds, :no, :charge_url,
             :base_unit, :quote_unit, :ask_alipay, :bid_alipay
  belongs_to :market
  belongs_to :ask, record_type: :order, serializer: OrderSerializer
  belongs_to :bid, record_type: :order, serializer: OrderSerializer
  belongs_to :ask_member, record_type: :user, serializer: UserSerializer
  belongs_to :bid_member, record_type: :user, serializer: UserSerializer
end
