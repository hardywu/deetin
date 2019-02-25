require 'test_helper'

class V1::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:member)
    @currency = coins(:one)
    @currency._run_create_callbacks
    @token_head = { 'Authorization' => "Bearer #{@user.jwt}" }
  end

  test 'should get orders' do
    get v1_accounts_url, headers: @token_head
    resp = JSON.parse(@response.body)
    assert_response :success
    assert_equal Currency.count, resp['data'].size
  end
end
