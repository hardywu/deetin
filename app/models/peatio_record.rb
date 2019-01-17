class PeatioRecord < ActiveRecord::Base
	establish_connection "peatio_#{Rails.env}".to_sym
  self.abstract_class = true
end
