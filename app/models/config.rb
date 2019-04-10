# == Schema Information
#
# Table name: configs
#
#  id    :string(255)      not null, primary key
#  value :string(255)
#

class Config < ApplicationRecord
  def self.[](name)
    find_or_create_by id: name
  end
end
