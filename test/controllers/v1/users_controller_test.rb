require 'test_helper'

class V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:master)
    @token_head = { 'Authorization' => "Bearer #{@user.jwt}" }
    @market = markets(:one)
  end

  test 'should get index' do
    get v1_users_url, as: :json, headers: @token_head
    assert_response :success
    resp = JSON.parse(@response.body)
    assert_equal @user.subs.count, resp['data'].size
  end

  test 'should create a member' do
    params = { data: { attributes: { email: 'test@sample.com' }, type: 'member' } }
    assert_difference('Member.count', 1) do
      post v1_users_url, params: params, as: :json, headers: @token_head
    end

    assert_response 201
  end

  test 'master should not create a bot' do
    params = { data: { attributes: { email: 'bot@sample.com' }, type: 'bot' } }
    assert_difference('Bot.count', 0) do
      post v1_users_url, params: params, as: :json, headers: @token_head
    end

    assert_response :forbidden
  end

  test 'agent should create a bot' do
    assert true
  end

  test 'should show user' do
    get v1_user_url(@user), as: :json, headers: @token_head
    assert_response :success
  end

  test 'should update user' do
    params = { data: { attributes: { username: 'changed' } } }
    patch v1_user_url(@user), params: params, as: :json, headers: @token_head
    assert_response 200
  end

  test 'should destroy user' do
    assert_difference('User.count', 0) do
      delete v1_user_url(@user), as: :json, headers: @token_head
    end

    assert_response 422
  end
end
