require 'test_helper'

class V1::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:member)
    @token_head = { 'Authorization' => "Bearer #{@user.jwt}" }
  end

  # test "should get index" do
  #   get profiles_url, as: :json
  #   assert_response :success
  # end

  # test "should create profile" do
  #   assert_difference('Profile.count') do
  #     post profiles_url, params: { profile: {  } }, as: :json
  #   end

  #   assert_response 201
  # end

  test 'should show my profile' do
    get v1_profile_url('me'), as: :json, headers: @token_head
    assert_response :success
  end

  # test "should update profile" do
  #   patch profile_url(@profile), params: { profile: {  } }, as: :json
  #   assert_response 200
  # end

  # test "should destroy profile" do
  #   assert_difference('Profile.count', -1) do
  #     delete profile_url(@profile), as: :json
  #   end

  #   assert_response 204
  # end
end
