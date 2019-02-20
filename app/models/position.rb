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
