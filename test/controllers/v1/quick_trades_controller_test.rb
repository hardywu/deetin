require 'test_helper'

class V1::QuickTradesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    @user = users(:member)
    @master = users(:master)
    @market = markets(:GX)
    @bid = orders(:bid)
    @ask = orders(:ask)
    @token_head = { 'Authorization' => "Bearer #{@user.jwt}" }
    @body = <<-RES
      {
        "sign":"ERITJKEIJKJHKKKKKKKHJEREEEEEEEEEEE",
        "alipay_trade_precreate_response":{
          "code":"10000",
          "qr_code":"http://qr.alipay.com/dfdsfsdfs",
          "msg":"Success"
        }
      }
    RES
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

  test 'should not create quick trade without approved secret' do
    stub_request(:post, 'https://openapi.alipaydev.com/gateway.do')
      .to_return(body: @body)

    assert_difference('Trade.count', 0) do
      post v1_quick_bid_url, params: quick_params(@user)
      assert_response :unprocessable_entity
    end
  end

  test 'should create quick trade sign uid/sign' do
    stub_request(:post, 'https://openapi.alipaydev.com/gateway.do')
      .to_return(body: @body)

    params = quick_params(@master)
    params['sign'] = @master.encript_sign params.to_query
    assert_difference('Trade.count') do
      post v1_quick_bid_url, params: params
      assert_includes @response.body, 'chargeUrl'
      assert_includes @response.body, 'no'
      assert_response :success
    end
  end

  test 'should done quick trade by alipay notify' do
    @trade = trades(:quick_trade)
    body = { out_trade_no: @trade.no }
    assert_equal 'Bot', @trade.ask_member.type
    assert_changes -> { @trade.state + @trade.ask_member.sales.to_s },
                   from: 'waiting0', to: 'done10.0' do
      post v1_quick_done_url, params: body
      assert_equal @trade.funds.to_s, @trade.ask_member.sales.to_s
      assert_response :success
      @trade.reload
    end
  end
end
