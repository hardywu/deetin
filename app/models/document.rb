# == Schema Information
#
# Table name: documents
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        unsigned, not null
#  upload     :string(255)
#  doc_type   :string(255)
#  doc_number :string(255)
#  doc_expire :date
#  metadata   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Document < ApplicationRecord
  has_one_attached :upload

  TYPES = ['Passport', 'Identity card', 'Driver license', 'Utility Bill'].freeze
  STATES = %w[verified pending rejected].freeze

  scope :kept, -> { joins(:user).where(users: { discarded_at: nil }) }

  belongs_to :user
  serialize :metadata, JSON
  validates :doc_type, :doc_number, :doc_expire, :upload, presence: true
  validates :doc_type, inclusion: { in: TYPES }

  validates :doc_number, length: { maximum: 128 },
                         format: {
                           with: /\A[A-Za-z0-9\-\s]+\z/,
                           message: 'only allows letters and digits'
                         }, if: proc { |a| a.doc_number.present? }
  validates_format_of :doc_expire,
                      with: /\A\d{4}\-\d{2}\-\d{2}\z/,
                      message: 'Date must be in the following format: yyyy-mm-dd'
  validate :doc_expire_not_in_the_past
  after_commit :create_or_update_document_label, on: :create

  private

  def doc_expire_not_in_the_past
    return if doc_expire.blank?

    errors.add(:doc_expire, :invalid) if doc_expire < Date.current
  end

  def create_or_update_document_label
    user_document_label = user.labels.find_by(key: :document)
    if user_document_label.nil?
      user.labels.create(key: :document, value: :pending, scope: :private)
    elsif user_document_label.value != 'verified'
      user_document_label.update(value: :pending)
    end
  end
end
