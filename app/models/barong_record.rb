class BarongRecord < ActiveRecord::Base
	establish_connection "barong_#{Rails.env}".to_sym
  self.abstract_class = true
end
