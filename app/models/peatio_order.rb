class PeatioOrder < PeatioRecord
  self.table_name = 'orders'

  include BelongsToMember
  enum state: { wait: 100, done: 200, cancel: 0 }
  scope :active, -> { where(state: :wait) }
end
