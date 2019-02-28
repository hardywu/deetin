require 'test_helper'

class V1::TradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:master)
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
      bid_id: @bid.id
    }, rela: { market: { data: { id: @market.id } } }
    assert_difference('Trade.count') do
      post v1_trades_url, params: data, headers: @token_head
      assert_response :success
    end
    resp = JSON.parse(@response.body)
    assert_response :success
    assert_not_nil resp['data']['id']
  end

  test 'should create quick trade' do
    bider = @user.members.create email: 'member@test.io'
    bot = @user.bots.create email: 'bot@test.io'
    acc = bot.accounts.find_by currency_id: @market.base_unit
    acc.update balance: 100_000
    data = attrs_formt attrs: {
      market_id: @market.id,
      funds: 1000,
      price: 100,
      volume: 10,
      bid_member_id: bider.id
    }
    assert_difference('Trade.count') do
      post quick_bid_v1_trades_url, params: data, headers: @token_head
      assert_response :success
    end
    resp = JSON.parse(@response.body)
    assert_response :success
    assert_not_nil resp['data']['id']
  end

  test 'should done trade' do
    assert true
  end
end
