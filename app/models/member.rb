require 'securerandom'
class Member < PeatioRecord
  has_many :orders, dependent: :restrict_with_error
  has_many :accounts, dependent: :restrict_with_error
  has_many :otc_accounts, dependent: :restrict_with_error
  has_many :transfers, dependent: :restrict_with_error

  scope :enabled, -> { where(state: 'active') }

  before_validation :downcase_email

  validates :email, presence: true, uniqueness: true, email: true
  validates :level, numericality: { greater_than_or_equal_to: 0 }
  validates :role, inclusion: { in: %w[member admin] }
  attr_readonly :email

  def trades
    Trade.where('bid_member_id = ? OR ask_member_id = ?', id, id)
  end

  def admin?
    role == 'admin'
  end

  def get_account(model_or_id_or_code)
    accounts.with_currency(model_or_id_or_code).first.yield_self do |account|
      touch_accounts unless account
      accounts.with_currency(model_or_id_or_code).first
    end
  end

  def balance_for(currency:, kind:)
    account_code = Operations::Chart.code_for(
      type: :liability,
      kind: kind,
      currency_type: currency.type
    )
    query_params = { member_id: id, currency: currency, code: account_code }
    liabilities = Operations::Liability.where(query_params)
    liabilities.sum('credit - debit')
  end

  def legacy_balance_for(currency:, kind:)
    if kind.to_sym == :main
      ac(currency).balance
    elsif kind.to_sym == :locked
      ac(currency).locked
    else
      raise Operations::Exception, "Account for #{options} doesn't exists."
    end
  end

  private

  def downcase_email
    self.email = email.try(:downcase)
  end

  class << self
    def uid(member_id)
      Member.find_by(id: member_id).uid
    end

    def from_payload(payload)
      ids, params = split_payload(payload)
      validate_payload(params)
      member = Member.find_or_create_by(ids) do |m|
        m.role = params[:role]
        m.state = params[:state]
        m.level = params[:level]
      end
      member.assign_attributes(params)
      member.save if member.changed?
      member
    end

    def split_payload(payload)
      id_params = { uid: payload[:uid], email: payload[:email] }
      [id_params, filter_payload(payload)]
    end

    # Filter and validate payload params
    def filter_payload(payload)
      payload.slice(:email, :uid, :role, :state, :level)
    end

    def validate_payload(payload)
      fetch_email(payload)
      payload.fetch(:uid).tap { |uid| validate_presence('UID', uid) }
      payload.fetch(:role).tap { |role| validate_presence('Role', role) }
      payload.fetch(:level).tap { |level| validate_presence('Level', level) }
      payload.fetch(:state).tap { |state| validate_state(state) }
    end

    def validate_presence(key, val)
      raise(Peatio::Auth::Error, "#{key} is blank.") if val.blank?
    end

    def validate_state(state)
      validate_presence('State', state)
      return if state == 'active'

      raise(Peatio::Auth::Error, 'State is not active.')
    end

    def fetch_email(payload)
      payload[:email].to_s.tap do |email|
        validate_presence('E-Mail', email)
        unless EmailValidator.valid?(email)
          raise(Peatio::Auth::Error, 'E-Mail is invalid.')
        end
      end
    end
  end
end
