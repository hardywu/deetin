
require 'test_helper'

class BotTest < ActiveSupport::TestCase
  setup do
    @bot = users(:bot)
  end

  test 'bot jwt format' do
    assert_equal @bot.jwt.split('.').length, 3
  end
end
