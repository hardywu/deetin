class UserPolicy < ApplicationPolicy
  def create?
    %w[admin].include? user.role
  end

  def update?
    user.role == 'admin' or not record.published?
  end
end
