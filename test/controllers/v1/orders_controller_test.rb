require 'test_helper'

class V1::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:member)
    @market = markets(:GX)
    @token_head = { 'Authorization' => "Bearer #{@user.jwt}" }
  end

  test 'should create bid' do
    data = { data: { attributes: { price: 232, volume: 4, ord_type: 'limit' }, type: 'bid', relationships: { market: { data: { id: @market.id } } } } }
    post v1_orders_url, params: data, headers: @token_head
    assert_response :success
  end

  test 'should create ask' do
    account = accounts(:member)
    data = { data: { attributes: { price: 232, volume: 4, ord_type: 'limit' }, type: 'ask', relationships: { market: { data: { id: @market.id } } } } }
    post v1_orders_url, params: data, headers: @token_head
    assert_response :success
    assert_equal account.balance - 4, Account.find(account.id).balance
    assert_equal account.locked + 4, Account.find(account.id).locked
  end

  test 'should get orders' do
    get v1_orders_url, headers: @token_head
    resp = JSON.parse(@response.body)
    assert_response :success
    assert_equal Order.count, resp['data'].size
  end
end
