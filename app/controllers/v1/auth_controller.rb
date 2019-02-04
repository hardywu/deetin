class V1::AuthController < V1::ApplicationController
  before_action :set_phone, only: :phone_vcode
  before_action :verify_phone, only: :signup
  before_action :set_user, only: :signin

  def signup
    @user = User.new user_params
    phone = @user.phones.new number: params[:phone_number]
    phone.code = @code

    if @user.save
      response.headers['JWT'] = @user.jwt
      render json: serialize(@user), status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def phone_vcode
    phone = Phone.new(number: @phone_number)
    captcha_key = "verify/#{@phone_number}/code"
    phone.code = Rails.cache.fetch(captcha_key, expires_in: 34.minutes) do
      phone.code
    end

    Phone.send_confirmation_sms(phone)
    render json: { message: '验证短信发送成功' }
  end

  def signin
    if @user.authenticate params[:password]
      response.headers['JWT'] = @user.jwt
      render json: serialize(@user), status: :ok
    else
      raise Peatio::Auth::Error, '登录失败'
    end
  end

  private

  def set_user
    @user = User.find_by! uid: params[:uid]
  end

  def serialize(user)
    UserSerializer.new(user).serialized_json
  end

  def set_phone
    raise InvalidParamError unless Phone.valid?(params[:phone_number])

    @phone_number = Phone.international(params[:phone_number])
  end

  def verify_phone
    @code = Rails.cache.fetch "verify/#{params[:phone_number]}/code"
    return unless @code != params[:vcode]

    raise InvalidParamError, 'Verification Code is invalid'
  end

  def parse_refid!
    refid_valid = /\AID\w{10}$/.match?(params[:refid])
    raise InvalidParamError, 'Invalid referral uid format' unless refid_valid

    user = User.find_by(uid: params[:refid])
    raise InvalidParamError, "Referral doesn't exist" if user.nil?

    user.id
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    build_params = {
      state: 'active',
      email: "#{set_phone}@nu0.one",
      password: params[:password]
    }
    build_params[:referral_id] = parse_refid! unless params[:refid].nil?
    logger.info build_params
    build_params
  end
end
