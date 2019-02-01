class Label < ApplicationRecord
  belongs_to :user

  SCOPES =
    HashWithIndifferentAccess.new(
      public: 'public', private: 'private'
    )

  SCOPES.keys.each do |name|
    define_method "#{name}?" do
      scope == SCOPES[name]
    end
  end

  scope :kept, -> { joins(:user).where(users: { discarded_at: nil }) }

  scope :with_private_scope, -> { where(scope: 'private') }

  validates :user_id, :key, :value, :scope, presence: true

  validates :scope,
            inclusion: { in: SCOPES.keys }

  validates :key,
            length: 3..255,
            format: { with: /\A[a-z0-9_-]+\z/ },
            uniqueness: { scope: %i[user_id scope] }

  validates :value,
            length: 3..255,
            format: { with: /\A[a-z0-9_-]+\z/ }

  after_commit :update_level_if_label_defined, on: %i[create update]
  after_destroy :update_level_if_label_defined
  before_validation :normalize_fields

  private

  def normalize_fields
    self.key = key.to_s.downcase.squish
    self.value = value.to_s.downcase.squish
  end

  def update_level_if_label_defined
    _cond = scope == 'private' || previous_changes[:scope]&.include?('private')
    return unless _cond

    user.update_level
    send_document_review_notification if key == 'document'
  end
end
