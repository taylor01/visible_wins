class Admin::ScheduleStatusesController < ApplicationController
  before_action :require_admin
  before_action :set_schedule_status, only: [ :show, :edit, :update, :destroy ]

  def index
    @schedule_statuses = ScheduleStatus.ordered
  end

  def show
  end

  def new
    @schedule_status = ScheduleStatus.new
    # Set default sort_order to next available
    @schedule_status.sort_order = (ScheduleStatus.maximum(:sort_order) || 0) + 1
  end

  def create
    @schedule_status = ScheduleStatus.new(schedule_status_params)

    if @schedule_status.save
      redirect_to admin_schedule_statuses_path, notice: "Schedule status was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @schedule_status.update(schedule_status_params)
      redirect_to admin_schedule_statuses_path, notice: "Schedule status was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule_status.destroy
    redirect_to admin_schedule_statuses_path, notice: "Schedule status was successfully deleted."
  end

  private

  def set_schedule_status
    @schedule_status = ScheduleStatus.find(params[:id])
  end

  def schedule_status_params
    params.require(:schedule_status).permit(:name, :display_name, :color_class, :sort_order, :active)
  end
end
