class ResetSalesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    keys = Bot.ids.map { |x| "bot_sales/#{x}" }
    Rails.cache.write_multi(Hash[[keys, [0] * keys.size].transpose])
  end
end
