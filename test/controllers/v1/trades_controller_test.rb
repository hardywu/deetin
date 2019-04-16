require 'test_helper'

class V1::TradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:member)
    @market = markets(:GX)
    @bid = orders(:bid)
    @ask = orders(:ask)
    @token_head = { 'Authorization' => "Bearer #{@user.jwt}" }
  end

  def attrs_formt(attrs:, rela: nil)
    { data: { attributes: attrs, relationships: rela }.compact }
  end

  test 'should create trade' do
    data = attrs_formt attrs: {
      funds: 1000,
      price: 100,
      volume: 10,
      ask_id: @ask.id,
      bid_id: @bid.id,
      market_id: @market.id
    }
    assert_difference('Trade.count') do
      post v1_trades_url, params: data, headers: @token_head
      assert_response :success
    end
    resp = JSON.parse(@response.body)
    assert_response :success
    assert_not_nil resp['data']['id']
  end
end
