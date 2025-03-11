class PagesController < ApplicationController
  def home
    @deals = Deal.all
  end

  def dashboard
    @user = current_user
  end
end
