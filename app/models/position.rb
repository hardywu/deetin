# == Schema Information
#
# Table name: positions
#
#  id         :bigint(8)        not null, primary key
#  user_id    :integer          not null
#  market_id  :integer          not null
#  volume     :integer          default(0), not null
#  margin     :decimal(32, 16)  default(0.0), not null
#  credit     :decimal(32, 16)  default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Position < ApplicationRecord
  belongs_to :user
  belongs_to :market

  def pnl
    credit + volume * Global[market_id].ticker[:last]
  end

  def lose
    _ = pnl
    (_.abs - _) / 2
  end

  def dmargin(dcredit)
    _ = market.margin_rate * (credit + dcredit).abs - margin + lose
    (_.abs + _) / 2
  end
end
