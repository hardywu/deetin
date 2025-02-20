require 'test_helper'

class V1::PositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:member)
    @market = futures_markets(:futures_one)
    @market._run_create_callbacks
    @token_head = { 'Authorization' => "Bearer #{@user.jwt}" }
  end

  test 'should get orders' do
    get v1_positions_url, headers: @token_head
    resp = JSON.parse(@response.body)
    assert_response :success
    assert_equal FuturesMarket.count, resp['data'].size
  end
end
