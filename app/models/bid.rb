# == Schema Information
#
# Table name: orders
#
#  id             :bigint(8)        not null, primary key
#  type           :string(8)        not null
#  base           :string(10)       not null
#  quote          :string(10)       not null
#  market_id      :string(20)       not null
#  price          :decimal(32, 16)
#  volume         :decimal(32, 16)  not null
#  origin_volume  :decimal(32, 16)  not null
#  fee            :decimal(32, 16)  default(0.0), not null
#  state          :integer          default("waiting"), not null
#  user_id        :integer          not null
#  funds_received :decimal(32, 16)  default(0.0)
#  trades_count   :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  ord_type       :string(255)      default("limit"), not null
#

class Bid < Order
  def lock_funds!(_vol) end
end
