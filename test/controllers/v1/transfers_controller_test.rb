require 'test_helper'
require 'helpers/auth_helper'
require 'helpers/peatio_helper'

class V1::TransfersControllerTest < ActionDispatch::IntegrationTest
  include AuthHelper
  include PeatioHelper

  setup do
    @transfer = transfers(:one)
    @member = members(:one)
    @token = jwt_for(@member)
  end

  test 'should get index' do
    headers = { "Authorization": "Bearer #{@token}" }
    get v1_transfers_url, as: :json, headers: headers
    assert_response :success
  end

  test 'should create transfer' do
    assert_difference('Transfer.count') do
      params = { amount: 100, currency_id: 'btc' }
      post v1_transfers_url, params: params, as: :json
    end

    assert_response 201
  end

  test 'should show transfer' do
    headers = { "Authorization": "Bearer #{@token}" }
    get v1_transfer_url(@transfer), as: :json, headers: headers
    assert_response :success
  end
end
