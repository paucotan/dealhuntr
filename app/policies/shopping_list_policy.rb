class ShoppingListPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  def index?
    user.present? # Users must be logged in to view their shopping list
  end

  def create?
    user.present? # Only logged-in users can add items to the shopping list
  end

  def update?
    user.present? # Only logged-in users can update their list
  end

  def destroy?
    user.present? # Only logged-in users can remove items
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    class Scope < Scope
      def resolve
        scope.where(user: user) # Only return the current user's shopping lists
      end
    end
  end
end
