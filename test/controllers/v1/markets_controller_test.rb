require 'test_helper'

class V1::MarketsControllerTest < ActionDispatch::IntegrationTest
  test "the truth" do
    get v1_markets_url
    assert_response :success
  end
end
