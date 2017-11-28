class TimeclockRecordsController < ApplicationController
  before_action :check_permission
  before_action :set_timeclock_record, only: [:update, :destroy]

  has_scope :with_week
  has_scope :with_employee
  has_scope :with_notes

  def index
    @employee = User.find_by_id session[:ipad_user_id] || current_user
    @timeclock_record = TimeclockRecord.find(params[:id]) if params[:id]
    @timeclock_records = TimeclockRecord.where('user_id = ? AND record_timestamp >= ?', @employee.id, Date.today.beginning_of_week - 1).order(record_timestamp: :desc)
    @flagged_records = TimeclockRecord.where('user_id = ? AND is_flagged = ?', @employee.id, true)
    @timed_redirect = true if params[:timed_redirect]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @timeclock_record = TimeclockRecord.new timeclock_record_params
    if @timeclock_record.save
      if params[:timeclock_record][:ipad_submit] # Successful clock punch from IPad
        session.delete(:ipad_user)
        flash[:success] = params[:timeclock_record][:success_message]
        redirect_to controller: 'timeclock_records', action: 'index', timed_redirect: true and return
      end
      redirect_to manage_records_timeclock_records_path, notice: 'Timeclock record was successfully created.' and return
    else
      if params[:timeclock_record][:ipad_submit] # Failed clock punch from IPad
        flash[:error] = params[:timeclock_record][:failure_message]
        redirect_to controller: 'ipad', action: 'employee_action', pin: params[:timeclock_record][:user_pin] and return
      end
      @timeclock_records = TimeclockRecord.all.order(record_timestamp: :desc)
      @closable_periods = Period.where('period_end_date < ? AND is_closed IS FALSE', Date.current)
      render :manage_records
    end
  end

  def update
    if @timeclock_record.update timeclock_record_params
      if params[:timeclock_record][:is_flagged]
        FlaggedRecordMailer.flagged_record_email(@timeclock_record, params[:timeclock_record][:note_to_supervisor]).deliver
        redirect_to timeclock_records_path, notice: 'Note successfully sent to supervisor.' and return
      end
      redirect_to manage_records_timeclock_records_path, notice: 'Timeclock record was successfully updated.'
    else
      if params[:timeclock_record][:is_flagged]
        @timeclock_record.errors.add(:timeclock_record, 'Record could not be flagged. Please contact IT for help.')
        @employee = User.find_by_id session[:ipad_user_id] || current_user
        time_start = Period.where('is_closed IS FALSE').order(period_start_date: :asc).first.period_start_date
        @timeclock_records = apply_scopes(TimeclockRecord).where('record_timestamp >= ?', time_start).order(record_timestamp: :desc)
        @flagged_records = TimeclockRecord.where('user_id = ? AND is_flagged = ?', @employee.id, true)
        render 'index' and return
      end
      time_start = Period.where('is_closed IS FALSE').order(period_start_date: :asc).first.period_start_date
      @timeclock_records = apply_scopes(TimeclockRecord).where('record_timestamp >= ?', time_start).order(record_timestamp: :desc)
      @closable_periods = Period.where('period_end_date < ? AND is_closed IS FALSE', Date.current)
      render 'manage_records'
    end
  end

  def destroy
    if @timeclock_record.send(:soft_delete)
      redirect_to manage_records_timeclock_records_path, notice: 'Timeclock record was successfully deleted.'
    else
      redirect_to manage_records_timeclock_records_path, notice: 'Failed to delete record. Contact IT for help.'
    end
  end

  def manage_records
    @timeclock_record = params[:id] ? TimeclockRecord.find(params[:id]) : TimeclockRecord.new
    @closable_periods = Period.where('period_end_date < ? AND is_closed IS FALSE', Date.current)
    time_start = Period.where('is_closed IS FALSE').order(period_start_date: :asc).first.period_start_date
    @timeclock_records = apply_scopes(TimeclockRecord).where('record_timestamp >= ?', time_start).order(record_timestamp: :desc)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def reason_codes
    @reason_code = params[:id] ? ReasonCode.find(params[:id]) : ReasonCode.new
    @reason_codes = ReasonCode.all.order(code: :asc)
  end

  def clocked_in
    @clocked_in = User.all.where('current_status != ?', 'out').order(:employee_number)
  end

private

  def check_permission
    require_permission 'timeclock_records', 2
  end

  def set_timeclock_record
    @timeclock_record = TimeclockRecord.find(params[:id])
  end

  def timeclock_record_params
    params.require(:timeclock_record).permit(:user_id, :record_type, :record_timestamp, :submit_type, :reason_code_id, :ip_address,
                                             :edit_type, :edit_ip_address, :notes, :is_locked, :is_flagged, :is_deleted)
  end

end
