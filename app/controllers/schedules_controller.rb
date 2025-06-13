class SchedulesController < ApplicationController
  def index
    # Handle week navigation
    if params[:week_start_date].present?
      @current_week_start = Date.parse(params[:week_start_date])
    else
      @current_week_start = Date.current.beginning_of_week(:sunday)
    end

    @teams = Team.all.order(:name)
    @selected_team = params[:team_id].present? ? Team.find(params[:team_id]) : nil

    # Calculate previous and next week dates
    @previous_week = @current_week_start - 1.week
    @next_week = @current_week_start + 1.week

    # Get users with team preloaded
    users_scope = User.includes(:team).by_name
    users_scope = users_scope.where(team: @selected_team) if @selected_team
    @users = users_scope

    # Single query to get all schedules for current week
    @schedules = WeeklySchedule.where(user_id: @users.pluck(:id), week_start_date: @current_week_start)
                               .index_by(&:user_id)
  end

  def edit
    @user = User.find(params[:id])
    redirect_to root_path and return unless @user == current_user

    # Default to next week if it's Thursday or later and no specific week is requested
    if params[:week_start_date].present?
      @week_start_date = params[:week_start_date].to_date
    elsif Date.current.wday >= 4 # Thursday (4) or later
      @week_start_date = Date.current.beginning_of_week(:sunday) + 1.week
    else
      @week_start_date = Date.current.beginning_of_week(:sunday)
    end

    @schedule = @user.weekly_schedules.find_or_initialize_by(week_start_date: @week_start_date)
    @schedule_options = WeeklySchedule::SCHEDULE_OPTIONS
  end

  def update
    @user = User.find(params[:id])
    redirect_to root_path and return unless @user == current_user

    # Get week_start_date from the form's hidden field or fallback to current week
    if params[:weekly_schedule]&.[](:week_start_date).present?
      @week_start_date = params[:weekly_schedule][:week_start_date].to_date
    else
      @week_start_date = Date.current.beginning_of_week(:sunday)
    end

    @schedule = @user.weekly_schedules.find_or_initialize_by(week_start_date: @week_start_date)

    if @schedule.update(schedule_params)
      redirect_to root_path, notice: "Schedule updated successfully!"
    else
      @schedule_options = WeeklySchedule::SCHEDULE_OPTIONS
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def schedule_params
    params.require(:weekly_schedule).permit(:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :week_start_date)
  end
end
