# == Schema Information
#
# Table name: payments
#
#  id         :bigint(8)        not null, primary key
#  type       :string(255)
#  name       :string(255)
#  no         :string(255)
#  desc       :text(65535)
#  user_id    :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Payment < ApplicationRecord
  belongs_to :user
end
