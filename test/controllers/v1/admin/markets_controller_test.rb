require 'test_helper'

class V1::Admin::MarketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin)
    @token_head = { 'Authorization' => "Bearer #{@user.jwt}" }
    @market = markets(:BTC)
  end

  test 'should update market' do
    params = { data: { attributes: { name: 'new name' } } }
    put v1_admin_market_url(@market), params: params, headers: @token_head
    assert_response :success
    market = Market.find @market.id
    assert_equal 'new name', market.name
  end
end
