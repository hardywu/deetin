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
#  payment_type    :string(255)
#  payment_id      :bigint(8)
#  device_id       :string(255)
#

class UserSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :email, :uid, :state, :level, :domain, :role, :username,
             :otp, :referral_id, :created_at, :status, :enabled, :secret,
             :payment_type, :device_id, :payment_id
  attribute :jwt, if: proc { |_record, params|
    params[:jwt]
  }

  attribute :sales, if: proc { |record|
    record.type == 'Bot'
  }

  has_one :profile
  has_one :payment, polymorphic: true
  has_many :payments, polymorphic: true
end
