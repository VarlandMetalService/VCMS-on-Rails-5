class TimeclockRecordsController < ApplicationController
  before_action :set_timeclock_record, only: [:show, :edit, :update, :destroy]
  before_action :check_permission

  def index
    @employee = User.find_by_id session[:ipad_user_id] || current_user
    @timeclock_records = TimeclockRecord.where('user_id = ? AND record_timestamp >= ?', @employee.id, Date.today.beginning_of_week - 1).order(record_timestamp: :desc)
    @flagged_records = TimeclockRecord.where('user_id = ? AND is_flagged = ?', @employee.id, true)
    @timed_redirect = true if params[:timed_redirect]
  end

  def create
    puts "PARAMS: #{timeclock_record_params}"
    @timeclock_record = TimeclockRecord.new timeclock_record_params
    if @timeclock_record.save
      if params[:timeclock_record][:ipad_submit]
        session.delete(:ipad_user)
        flash[:success] = params[:timeclock_record][:success_message]
        redirect_to controller: 'timeclock_records', action: 'index', timed_redirect: true and return
      end
      redirect_to manage_records_timeclock_records_path, notice: 'Timeclock record was successfully created.' and return
    else
      if params[:timeclock_record][:ipad_submit]
        flash[:error] = params[:timeclock_record][:failure_message]
        redirect_to controller: 'ipad', action: 'employee_action', pin: params[:timeclock_record][:user_pin] and return
      end
      @timeclock_records = TimeclockRecord.all.order(record_timestamp: :desc)
      render :manage_records
    end
  end

  def update
    if @timeclock_record.update timeclock_record_params
      redirect_to manage_records_timeclock_records_path, notice: 'Timeclock record was successfully updated.'
    else
      @timeclock_records = TimeclockRecord.all.order(record_timestamp: :desc)
      render :manage_records
    end
  end

  def destroy
    @timeclock_record.destroy
    redirect_to timeclock_records_url, notice: 'Timeclock record was successfully deleted.'
  end

  def manage_records
    @timeclock_record = params[:id] ? TimeclockRecord.find(params[:id]) : TimeclockRecord.new
    @timeclock_records = TimeclockRecord.all.order(record_timestamp: :desc)
    @closable_periods = Period.where('period_start_date < ? AND is_closed IS FALSE', Date.current)
  end

  def reason_codes
    @reason_codes = ReasonCode.all.order(code: :asc)
  end

  def clocked_in
    @clocked_in = User.all.where('current_status != ?', 'out').order(:employee_number)
  end

  private
    def set_timeclock_record
      @timeclock_record = TimeclockRecord.find(params[:id])
    end

    def timeclock_record_params
      params.require(:timeclock_record).permit(:user_id, :record_type, :record_timestamp, :submit_type, :reason_code_id, :ip_address, :edit_type, :edit_ip_address, :notes, :is_locked, :is_flagged)
    end

    def check_permission
      require_permission 'sysadmin', 2
    end

end
