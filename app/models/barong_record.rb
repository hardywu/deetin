class BarongRecord < ActiveRecord::Base
	establish_connection "barong_#{Rails.env}"
  self.abstract_class = true
end
