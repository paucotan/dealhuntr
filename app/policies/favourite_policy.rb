class FavouritePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  def create?
    user.present?
  end

  def destroy?
    user.present?
  end
end
