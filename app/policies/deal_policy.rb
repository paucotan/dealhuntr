class DealPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all # Allow all users to see deals
    end
  end

  def index?
    true # Anyone can view deals
  end

  def show?
    true # Anyone can view a deal's details
  end

  def create?
    user.present? # Only logged-in users can create deals
  end

  def update?
    user.present? # Only logged-in users can update deals
  end

  def destroy?
    user.present? # Only logged-in users can delete deals
  end

  def related?
    true
  end
end
