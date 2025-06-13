class ProfileController < ApplicationController
  def show
    @user = current_user
  end

  def edit
    @user = current_user
    @teams = Team.all.order(:name)
  end

  def update
    @user = current_user
    @teams = Team.all.order(:name)

    if @user.update(user_params)
      # Mark profile as completed if this is first time
      if !@user.profile_completed?
        @user.update!(profile_completed_at: Time.current)
        redirect_to root_path, notice: "Welcome! Your profile has been completed successfully."
      else
        redirect_to profile_path, notice: "Profile updated successfully!"
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:team_id)
  end
end
