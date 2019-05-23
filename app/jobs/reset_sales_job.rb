class ResetSalesJob < ApplicationJob
  queue_as :default

  after_perform do
    self.class.set(wait_until: Time.zone.tomorrow.midnight).perform_later
  end

  def perform
    keys = Bot.ids.map { |x| "bot_sales/#{x}" }
    Rails.cache.write_multi(Hash[[keys, [0] * keys.size].transpose])
  end
end
