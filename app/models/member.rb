# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  uid             :string(255)      not null
#  domain          :string(255)      default("nanyazq.com"), not null
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
#  master_id       :bigint(8)
#  type            :string(255)
#

class Member < User
  belongs_to :master, class_name: 'User'
  before_validation -> { self.password = '000000' }

  def authenticate(_unencrypted_password)
    false
  end
end
