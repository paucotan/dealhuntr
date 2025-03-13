class StorePolicy < ApplicationPolicy
  def show?
    true
  end

  def home?
    true
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end
end
