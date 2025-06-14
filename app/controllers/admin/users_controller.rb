class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.includes(:team).by_name
  end

  def show
  end


  def edit
    @teams = Team.all.order(:name)
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully!"
    else
      @teams = Team.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      redirect_to admin_users_path, notice: "User deleted successfully!"
    else
      redirect_to admin_users_path, alert: "Cannot delete user: #{@user.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    # Only allow editing of local override fields (Okta fields are read-only)
    permitted_params = [ :role, :team_id, :active ]
    permitted_params << :admin if current_user&.admin?

    params.require(:user).permit(permitted_params)
  end
end
