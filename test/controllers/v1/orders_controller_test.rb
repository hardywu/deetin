require 'test_helper'

class V1::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:member)
    @market = markets(:one)
    @token_head = { 'Authorization' => "Bearer #{@user.jwt}" }
  end

  test 'should create order' do
    data = { data: { attributes: { price: 232, volume: 4, ord_type: 'limit' }, type: 'bid', relationships: { market: { data: { id: @market.id } } } } }
    post v1_orders_url, params: data, headers: @token_head
    assert_response :success
  end

  test 'should get orders' do
    get v1_orders_url, headers: @token_head
    resp = JSON.parse(@response.body)
    assert_equal @user.orders.count, resp['data'].size
  end
end
