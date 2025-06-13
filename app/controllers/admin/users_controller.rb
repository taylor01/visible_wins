class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.includes(:team).by_name
  end

  def show
  end

  def new
    @user = User.new
    @teams = Team.all.order(:name)
  end

  def create
    @user = User.new(user_params)
    @teams = Team.all.order(:name)
    
    if @user.save
      redirect_to admin_users_path, notice: "User created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
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
    params.require(:user).permit(:first_name, :last_name, :email, :okta_sub, :role, :team_id, :admin, :active)
  end
end
