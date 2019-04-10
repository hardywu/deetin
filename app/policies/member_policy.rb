class MemberPolicy < ApplicationPolicy
  def create?
    %w[admin master].include? user.role
  end

  def update?
    user.role == 'admin' or not record.published?
  end
end
