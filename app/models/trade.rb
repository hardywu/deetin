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
    ask_member.alipay
  end

  def bid_alipay
    bid_member.alipay
  end

  attr_accessor :side

  def set_members
    self.trend = 'up'
    self.bid_member = bid.user
    self.ask_member = ask.user
    self.master = ask.user.master
  end

  class << self
    def latest_price(market)
      with_market(market).order(id: :desc).select(:price).first.try(:price) || ZERO
    end

    def filter(market, timestamp, from, to, limit, order)
      trades = with_market(market).order(order)
      trades = trades.limit(limit) if limit.present?
      trades = trades.where('created_at <= ?', timestamp) if timestamp.present?
      trades = trades.where('id > ?', from) if from.present?
      trades = trades.where('id < ?', to) if to.present?
      trades
    end

    def for_member(market, member, options={})
      trades = filter(market, options[:time_to], options[:from], options[:to], options[:limit], options[:order]).where("ask_member_id = ? or bid_member_id = ?", member.id, member.id)
      trades.each do |trade|
        trade.side = trade.ask_member_id == member.id ? 'ask' : 'bid'
      end
    end

    def avg_h24_price(market)
      with_market(market).h24.select(:price).average(:price).to_d
    end
  end
end
