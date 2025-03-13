class PagePolicy < ApplicationPolicy
  def home?
    true # ✅ Everyone can access the homepage
  end

  def search?
    true # ✅ Everyone can use search
  end

  def dashboard?
    user.present? # ❌ Only logged-in users can access the dashboard
  end

  class Scope < Scope
    def resolve
      scope.all # ✅ No scope restrictions needed for now
    end
  end
end
