class User < ApplicationRecord
  ROLES = %w[admin accountant compliance member].freeze

  has_secure_password

  has_many  :phones, dependent: :destroy
  has_many  :labels, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_many :positions, dependent: :restrict_with_error
  has_many :payments, dependent: :restrict_with_error
  has_many :accounts, foreign_key: :member_id,
                      inverse_of: :member,
                      dependent: :restrict_with_error
  validates :email, email: true, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  scope :active, -> { where(state: 'active') }

  before_validation :assign_uid
  after_create :after_confirmation
  after_create :touch_positions
  after_create :touch_accounts
  belongs_to :referrer, class_name: 'User', optional: true,
                        foreign_key: 'referral_id', inverse_of: :referees
  has_many :referees, class_name: 'User', foreign_key: 'referral_id',
                      inverse_of: :referrer, dependent: :restrict_with_error

  def active?
    state == 'active'
  end

  def role
    super.inquiry
  end

  def should_validate?
    new_record? || password.present?
  end

  def after_confirmation
    add_level_label(:phone)
    add_level_label(:email)
  end

  def touch_accounts
    Currency.find_each do |currency|
      next if accounts.where(currency: currency).exists?

      accounts.create!(currency: currency)
    end
  end

  def touch_positions
    FuturesMarket.find_each do |market|
      next if positions.where(market: market).exists?

      positions.create!(market: market)
    end
  end

  # FIXME: Clean level micro code
  def update_level
    tags = []
    user_level = 0
    tags = labels.with_private_scope
                 .map { |l| [l.key, l.value].join ':' }

    levels = Level.all.order(id: :asc)
    levels.each do |lvl|
      break unless tags.include?(lvl.key + ':' + lvl.value)

      user_level = lvl.id
    end

    update(level: user_level)
  end

  def add_level_label(key, value = 'verified')
    labels.find_or_create_by(key: key, scope: 'private')
          .update!(value: value)
  end

  def as_payload
    slice(%i[id uid email domain referral_id role level state])
  end

  def jwt
    JWT.encode as_payload, 'secret', 'HS256'
  end

  class << self
    def from_payload(p)
      params = filter_payload(p)
      validate_payload(params)
      member = User.find_or_create_by(uid: p[:uid], email: p[:email]) do |m|
        m.role = params[:role]
        m.state = params[:state]
        m.level = params[:level]
      end
      member.assign_attributes(params)
      member.save if member.changed?
      member
    end

    # Filter and validate payload params
    def filter_payload(payload)
      payload.slice(:email, :uid, :role, :state, :level)
    end

    def validate_payload(p)
      fetch_email(p)
      p.fetch(:uid).tap { |uid| raise(Peatio::Auth::Error, 'UID is blank.') if uid.blank? }
      p.fetch(:role).tap { |role| raise(Peatio::Auth::Error, 'Role is blank.') if role.blank? }
      p.fetch(:level).tap { |level| raise(Peatio::Auth::Error, 'Level is blank.') if level.blank? }
      p.fetch(:state).tap do |state|
        raise(Peatio::Auth::Error, 'State is blank.') if state.blank?
        raise(Peatio::Auth::Error, 'State is not active.') unless state == 'active'
      end
    end

    def fetch_email(payload)
      payload[:email].to_s.tap do |email|
        raise(Peatio::Auth::Error, 'E-Mail is blank.') if email.blank?
        raise(Peatio::Auth::Error, 'E-Mail is invalid.') unless EmailValidator.valid?(email)
      end
    end
  end

  private

  def assign_uid
    return if uid.present?

    loop do
      self.uid = random_uid
      break unless User.where(uid: uid).any?
    end
  end

  def random_uid
    Time.current.strftime '%3N%H%j%y%M'
  end
end
