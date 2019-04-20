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
  default_scope { order('created_at DESC') }
  include BelongsToMarket
  ZERO = '0.0'.to_d
  attr_accessor :side, :subject, :charge_url
  enum state: %i[done waiting cancelled]
  enum trend: { up: 1, down: 0 }
  scope :h24, -> { where('created_at > ?', 24.hours.ago) }
  validates :price, :volume, :funds,
            numericality: { greater_than_or_equal_to: 0.to_d }
  before_validation :set_extra_attrs

  belongs_to :market
  belongs_to :master, class_name: 'User', optional: true
  belongs_to :ask, class_name: 'Ask', foreign_key: :ask_id
  belongs_to :bid, class_name: 'Bid', foreign_key: :bid_id
  belongs_to :ask_member, class_name: 'User', foreign_key: :ask_member_id
  belongs_to :bid_member, class_name: 'User', foreign_key: :bid_member_id

  def generate_no
    self.no = Nanoid.generate alphabet: '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                              size: 32
    self
  end

  def base_unit
    Market.id_to_base(market_id)
  end

  def quote_unit
    Market.id_to_quote(market_id)
  end

  def ask_username
    ask_member&.username
  end

  def bid_username
    bid_member&.username
  end

  def create_charge_url
    response = ask_member.alipay_client.execute(
      method: 'alipay.trade.precreate',
      notify_url: Config['alipay_notify_url'].value,
      biz_content: biz_content
    ).encode('utf-8', 'gbk')
    res = JSON.parse(response)['alipay_trade_precreate_response']
    raise StandardError, res.to_s unless res['code'] == '10000'

    self.charge_url = res['qr_code']
    self
  end

  def biz_content
    JSON.generate({ out_trade_no: no,
                    timeout_express: '10m',
                    disable_pay_channels: 'credit_group,promotion',
                    total_amount: funds.round(2).to_s,
                    subject: subject }, ascii_only: true)
  end

  def quick_record!
    raise StandardError, 'no bid_member' unless bid_member_id

    ActiveRecord::Base.transaction do
      params = slice(%i[price volume market_id state]).symbolize_keys
      self.ask = Ask.create! user: ask_member, **params
      self.bid = Bid.create! user: bid_member, **params
      save!
      ask.lock_funds!(volume)
    end
  end

  def done_ask!
    ask.unlock_and_sub_funds!(volume)
    ask.volume -= volume
    ask.funds_received += funds
    ask.save!
  end

  def done_bid!
    bid.plus_funds!(volume)
    bid.volume -= volume
    bid.funds_received += funds
    bid.save!
  end

  def done_record!
    ActiveRecord::Base.transaction do
      done_ask!
      done_bid!
      update! state: 'done'
    end
  end

  def set_extra_attrs
    assign_attributes trend: 'up'
    self.bid_member_id ||= bid.user_id
    self.ask_member_id ||= ask.user_id
  end

  class << self
    def latest_price(market)
      trade = with_market(market).order(id: :desc).limit(1).first
      trade ? trade.price : 0
    end
  end
end
