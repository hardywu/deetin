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

class Member < User
  belongs_to :master, class_name: 'User',
                      primary_key: 'uid',
                      foreign_key: :domain
  before_validation :set_attrs

  def set_attrs
    self.password = '000000'
  end

  def authenticate(_unencrypted_password)
    false
  end
end
