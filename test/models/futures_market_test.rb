require 'test_helper'

class FuturesMarketTest < ActiveSupport::TestCase
  setup do
    @market = futures_markets(:futures_one)
  end

  test 'should match size' do
    assert_equal 1, FuturesMarket.count
    assert_operator FuturesMarket.count, '<', Market.count
  end
end
