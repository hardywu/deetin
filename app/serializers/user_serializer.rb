# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  uid             :string(255)      not null
#  domain          :string(255)
#  email           :string(255)      not null
#  password_digest :string(255)      not null
#  role            :string(255)      default("member"), not null
#  level           :integer          default(0), not null
#  state           :string(255)      default("pending"), not null
#  otp             :boolean          default(FALSE)
#  referral_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  username        :string(255)
#  type            :string(255)
#  enabled         :boolean          default(FALSE), not null
#  secret          :string(255)
#

class UserSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :email, :uid, :state, :level, :domain, :role, :username,
             :otp, :referral_id, :created_at, :status
  attribute :jwt, if: proc { |_record, params|
    params[:jwt]
  }
  attribute :alipay_no do |object|
    object.alipay&.no
  end

  has_one :alipay
  has_one :profile
  has_many :payments
end
