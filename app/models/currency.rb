class Currency < ApplicationRecord
  after_create { User.find_each(&:touch_accounts) }
end
