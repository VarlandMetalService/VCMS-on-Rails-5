class PeriodController < ApplicationController
  before_action :set_closable_period, only: [:update]
  before_action :check_permission

  def update
    if @closeable_period.update closeable_period_params
      redirect_to manage_records_timeclock_records_path, notice: 'Period was successfully closed.'
    else
      @timeclock_records = TimeclockRecord.all.order(record_timestamp: :desc)
      render :manage_records
    end
  end

private

  def set_closable_period
    @closeable_period = Period.find(params[:id])
  end

  def closeable_period_params
    params.require(:period).permit(:period_start_date, :period_end_date, :is_closed, :user_id, :closed_at, :ip_address)
  end

  def check_permission
    require_permission 'sysadmin', 2
  end

end
