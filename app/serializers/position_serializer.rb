# == Schema Information
#
# Table name: positions
#
#  id         :bigint(8)        not null, primary key
#  user_id    :integer          not null
#  market_id  :integer          not null
#  volume     :integer          default(0), not null
#  margin     :decimal(32, 16)  default(0.0), not null
#  credit     :decimal(32, 16)  default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PositionSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :credit, :margin
end
