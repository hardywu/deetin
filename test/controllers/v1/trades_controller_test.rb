require 'test_helper'

class V1::TradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:member)
    @master = users(:master)
    @market = markets(:GX)
    @bid = orders(:bid)
    @ask = orders(:ask)
    @token_head = { 'Authorization' => "Bearer #{@user.jwt}" }
    body = <<-RES
      {
        "sign":"ERITJKEIJKJHKKKKKKKHJEREEEEEEEEEEE",
        "alipay_trade_precreate_response":{
          "code":"10000",
          "qr_code":"http://qr.alipay.com/dfdsfsdfs",
          "msg":"Success"
        }
      }
    RES

    stub_request(:post, 'https://openapi.alipaydev.com/gateway.do')
      .to_return(body: body)

    stub_request(:post, 'https://api.nu0.one/callback').to_return(body: body)
  end

  def attrs_formt(attrs:, rela: nil)
    { data: { attributes: attrs, relationships: rela }.compact }
  end

  def quick_params(user)
    {
      funds: 1000,
      callback_url: 'text_backbacl',
      uid: user.uid,
      email: 'test_member@nu0.one'
    }.transform_keys! { |key| key.to_s.camelize :lower }
  end

  test 'should create trade' do
    data = attrs_formt attrs: {
      funds: 1000,
      price: 100,
      volume: 10,
      ask_id: @ask.id,
      bid_id: @bid.id,
      market_id: @market.id
    }
    assert_difference('Trade.count') do
      post v1_trades_url, params: data, headers: @token_head
      assert_response :success
    end
    resp = JSON.parse(@response.body)
    assert_response :success
    assert_not_nil resp['data']['id']
  end

  test 'should not create quick trade without approved secret' do
    assert_difference('Trade.count', 0) do
      post quick_bid_v1_trades_url, params: quick_params(@user)
      assert_response :unprocessable_entity
    end
  end

  test 'should create quick trade sign uid/sign' do
    params = quick_params(@master)
    params['sign'] = @master.encript_sign params.to_query
    assert_difference('Trade.count') do
      post quick_bid_v1_trades_url, params: params
      assert_includes @response.body, 'chargeUrl'
      assert_includes @response.body, 'no'
      assert_response :success
    end
  end

  test 'should done quick trade by alipay notify' do
    @trade = trades(:quick_trade)
    body = { out_trade_no: @trade.no }
    assert_changes -> { @trade.state }, from: 'waiting', to: 'done' do
      post quick_done_v1_trades_url, params: body
      assert_response :success
      @trade.reload
    end
  end
end
