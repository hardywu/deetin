require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:member)
  end

  test "user jwt format" do
    assert_equal @user.jwt.split('.').length, 3
  end
end
