class FuturesMarket < Market
  after_create { User.find_each(&:touch_positions) }
end
