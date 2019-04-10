# == Schema Information
#
# Table name: trades
#
#  id            :bigint(8)        not null, primary key
#  price         :decimal(32, 16)  not null
#  volume        :decimal(32, 16)  not null
#  trend         :integer          not null
#  market_id     :string(20)       not null
#  ask_member_id :integer          not null
#  bid_member_id :integer          not null
#  funds         :decimal(32, 16)  not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  master_id     :bigint(8)
#  state         :integer          default("done")
#  ask_id        :bigint(8)        not null
#  bid_id        :bigint(8)        not null
#  callback_url  :string(255)
#  no            :string(255)
#

class Trade < ApplicationRecord
  include BelongsToMarket
  ZERO = '0.0'.to_d
  attr_accessible :subject, :charge_url
  enum state: %i[done waiting cancelled]
  enum trend: { up: 1, down: 0 }
  scope :h24, -> { where('created_at > ?', 24.hours.ago) }
  validates :price, :volume, :funds,
            numericality: { greater_than_or_equal_to: 0.to_d }
  before_validation :set_extra_attrs

  belongs_to :market
  belongs_to :master, class_name: 'User'
  belongs_to :ask, class_name: 'Ask', foreign_key: :ask_id
  belongs_to :bid, class_name: 'Bid', foreign_key: :bid_id
  belongs_to :ask_member, class_name: 'User',
                          foreign_key: :ask_member_id
  belongs_to :bid_member, class_name: 'User',
                          foreign_key: :bid_member_id
  delegate :base_unit, to: :market
  delegate :quote_unit, to: :market

  def ask_alipay
    ask_member&.alipay
  end

  def bid_alipay
    bid_member&.alipay
  end

  def create_charge_url
    response = bid_member.alipay_client.execute(
      method: 'alipay.trade.precreate',
      notify_url: Config['alipay_notify_url'].value,
      biz_content: biz_content
    )
    JSON.parse(response)['alipay_trade_precreate_response']['qr_code']
  end

  def biz_content
    JSON.generate({ out_trade_no: no,
                    total_amount: funds.to_s,
                    subject: subject }, ascii_only: true)
  end

  def quick_record!
    ActiveRecord::Base.transaction do
      params = slice(%i[price volume market_id state]).symbolize_keys
      self.ask = Ask.create! user: ask_member, **params
      self.bid = Bid.create! user: bid_member, **params
      save!
      settle_funds!
    end
  end

  def done_ask!
    ask.unlock_and_sub_funds!(volume)
    ask.volume -= volume
    ask.funds_received += funds
    ask.state = 'done' if ask.volume == ZERO
    ask.save!
  end

  def done_bid!
    bid.plus_funds!(volume)
    bid.volume -= volume
    bid.funds_received += funds
    bid.state = 'done' if bid.volume == ZERO
    bid.save!
  end

  def done_record!
    ActiveRecord::Base.transaction do
      done_ask!
      done_bid!
      update! state: 'done'
    end
  end

  def settle_funds!
    if state == 'done'
      ask.sub_funds!(volume).update! state: 'done'
      bid.plus_funds!(volume).update! state: 'done'
    else
      ask.lock_funds!(volume)
    end
  end

  attr_accessor :side

  def set_extra_attrs
    assign_attributes no: Nanoid.generate, trend: 'up', funds: price * volume,
                      bid_member: bid.user, ask_member: ask.user,
                      master: ask.user.master
  end

  class << self
    def latest_price(market)
      trade = with_market(market).order(id: :desc).limit(1).first
      trade ? trade.price : 0
    end
  end
end
