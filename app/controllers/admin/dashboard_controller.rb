class Admin::DashboardController < ApplicationController
  before_action :require_admin

  def index
    @users_count = User.count
    @teams_count = Team.count
    @schedule_statuses_count = ScheduleStatus.count
    @active_users_count = User.where(active: true).count
  end
end