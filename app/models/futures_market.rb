# == Schema Information
#
# Table name: markets
#
#  id              :bigint(8)        not null, primary key
#  base_unit       :string(10)       not null
#  quote_unit      :string(10)       not null
#  base_precision  :integer          default(8), not null
#  quote_precision :integer          default(8), not null
#  enabled         :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  type            :string(255)
#  code            :string(255)
#  name            :string(255)
#

class FuturesMarket < Market
  after_create { User.find_each(&:touch_positions) }
end
