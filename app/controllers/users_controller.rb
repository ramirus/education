class UsersController < ApplicationController
  def show
    user_id = params[:id]
    @user = User.find(user_id)
    @user_workshops = User.where(user_id: user_id)
  end
end
