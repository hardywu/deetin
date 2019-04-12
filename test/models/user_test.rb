require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:member)
  end

  test 'user jwt format' do
    assert_equal @user.jwt.split('.').length, 3
  end

  test 'user verify sign for quick bid' do
    @master = users(:master)
    assert_raise StandardError do
      @master.verify_sign!('wrong', @master.encript_sign('correct'))
    end
    assert_nothing_raised do
      @master.verify_sign!('correct', @master.encript_sign('correct'))
    end
  end
end
