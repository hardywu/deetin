require 'test_helper'

class V1::AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
  end

  # test "should get index" do
  #   get users_url, as: :json
  #   assert_response :success
  # end

  # test "should create user" do
  #   assert_difference('User.count') do
  #     post users_url, params: { user: {  } }, as: :json
  #   end

  #   assert_response 201
  # end

  # test "should show user" do
  #   get user_url(@user), as: :json
  #   assert_response :success
  # end

  # test "should update user" do
  #   patch user_url(@user), params: { user: {  } }, as: :json
  #   assert_response 200
  # end

  # test "should destroy user" do
  #   assert_difference('User.count', -1) do
  #     delete user_url(@user), as: :json
  #   end

  #   assert_response 204
  # end
end
