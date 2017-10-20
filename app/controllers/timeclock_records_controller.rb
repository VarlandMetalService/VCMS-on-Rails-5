class TimeclockRecordsController < ApplicationController
  before_action :set_timeclock_record, only: [:show, :edit, :update, :destroy]

  def index
    @employee = User.find(session[:ipad_user_id]) || current_user
    @timeclock_records = TimeclockRecord.where('user_id = ?', @employee.id)
    @flagged_records = TimeclockRecord.where('user_id = ? AND is_flagged = ?', @employee.id, true)
  end

  def new
    @timeclock_record = TimeclockRecord.new
  end

  def edit
  end

  def create
    @timeclock_record = TimeclockRecord.new timeclock_record_params

    if @timeclock_record.save
      redirect_to @timeclock_record, notice: 'Timeclock record was successfully created.'
    else
      render :new
    end
  end

  def update
    if @timeclock_record.update timeclock_record_params
      redirect_to @timeclock_record, notice: 'Timeclock record was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @timeclock_record.destroy
    redirect_to timeclock_records_url, notice: 'Timeclock record was successfully destroyed.'
  end

  def reason_codes
    @reason_codes = ReasonCode.all.order(code: :asc)
  end

  def clocked_in
    @clocked_in = User.all.where('current_status != ?', 'out').order(:employee_number)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_timeclock_record
      @timeclock_record = TimeclockRecord.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def timeclock_record_params
      params.require(:timeclock_record).permit(:user_id, :record_type, :record_timestamp, :submit_type, :reason_code_id, :ip_address, :edit_type, :edit_ip_address, :notes, :is_locked, :is_flagged)
    end

end
