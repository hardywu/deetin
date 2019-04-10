# == Schema Information
#
# Table name: markets
#
#  base_precision  :integer          default(8), not null
#  quote_precision :integer          default(8), not null
#  enabled         :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  type            :string(255)
#  name            :string(255)
#  id              :string(20)       not null, primary key
#  position        :integer          default(0), not null
#

class MarketSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower
  attributes :base_unit, :quote_unit, :name
end
