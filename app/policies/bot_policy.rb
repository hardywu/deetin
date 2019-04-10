class BotPolicy < ApplicationPolicy
  def create?
    %w[admin agent].include? user.role
  end

  def update?
    user.role == 'admin' or not record.published?
  end
end
