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
#  state         :integer          default("done")
#  ask_id        :bigint(8)        not null
#  bid_id        :bigint(8)        not null
#

class Trade < ApplicationRecord
  include BelongsToMarket
  ZERO = '0.0'.to_d
  enum state: %i[done initiated waiting]
  enum trend: { up: 1, down: 0 }
  scope :h24, -> { where('created_at > ?', 24.hours.ago) }
  validates :price, :volume, :funds,
            numericality: { greater_than_or_equal_to: 0.to_d }
  before_validation :set_members

  belongs_to :market, required: true
  belongs_to :master, class_name: 'User'
  belongs_to :ask, class_name: 'Ask', foreign_key: :ask_id, required: true
  belongs_to :bid, class_name: 'Bid', foreign_key: :bid_id, required: true
  belongs_to :ask_member, class_name: 'User',
                          foreign_key: :ask_member_id,
                          required: true
  belongs_to :bid_member, class_name: 'User',
                          foreign_key: :bid_member_id,
                          required: true
  delegate :base_unit, to: :market
  delegate :quote_unit, to: :market

  def ask_alipay
    ask_member&.alipay
  end

  def bid_alipay
    bid_member&.alipay
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

  def settle_funds!
    if state == 'done'
      ask.sub_funds!(volume).update! state: 'done'
      bid.plus_funds!(volume).update! state: 'done'
    else
      ask.lock_funds!(volume)
    end
  end

  attr_accessor :side

  def set_members
    self.trend = 'up'
    self.funds = price * volume
    self.bid_member ||= bid.user
    self.ask_member ||= ask.user
    self.master ||= ask.user.master
  end

  class << self
    def latest_price(market)
      with_market(market).order(id: :desc).select(:price).first.try(:price) ||
        ZERO
    end

    def filter(market, *opts)
      trades = with_market(market).order(opts[:order])
      trades = trades.limit(opts[:limit]) if opts[:limit].present?
      if opts[:timestamp].present?
        trades = trades.where('created_at <= ?', opts[:timestamp])
      end
      trades = trades.where('id > ?', opts[:from]) if opts[:from].present?
      trades = trades.where('id < ?', opts[:to]) if opts[:to].present?
      trades
    end

    def for_member(market, member, options = {})
      trades = filter market, **options.slice(%i[time_to from to limit order])
      trades = trades.where('ask_member_id = ? or bid_member_id = ?', member.id, member.id)
      trades.each do |trade|
        trade.side = trade.ask_member_id == member.id ? 'ask' : 'bid'
      end
    end

    def avg_h24_price(market)
      with_market(market).h24.select(:price).average(:price).to_d
    end
  end
end
