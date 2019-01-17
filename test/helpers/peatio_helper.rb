# encoding: UTF-8
# frozen_string_literal: true

module PeatioHelper
  def payload
    {
      email: 'admin@barong.io',
      uid: 'U123456789',
      role: 'admin',
      state: 'active',
      level: '3'
    }
  end
end
