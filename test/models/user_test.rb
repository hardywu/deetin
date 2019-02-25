require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    Rails.logger.info 'mcguuu'
    Rails.logger.info User.connection_config
    @user = users(:member)
  end

  test 'user jwt format' do
    assert_equal @user.jwt.split('.').length, 3
  end
end
