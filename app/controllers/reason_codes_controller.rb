class ReasonCodesController < ApplicationController
  before_action :set_reason_code, only: [:update, :destroy]
  before_action :check_permission

  def index
    @reason_code = params[:id] ? ReasonCode.find(params[:id]) : ReasonCode.new
    @reason_codes = ReasonCode.all.order(code: :asc)
  end

  def create
    @reason_code = TimeclockRecord.new reason_code_params
    if @reason_code.save
      redirect_to reason_codes_path, notice: 'Reason code was successfully created.' and return
    else
      @reason_codes = TimeclockRecord.all.order(record_timestamp: :desc)
      render :reason_codes
    end
  end

  def update
    if @reason_code.update reason_code_params
      redirect_to reason_codes_path, notice: 'Reason code was successfully updated.'
    else
      @reason_codes = TimeclockRecord.all.order(record_timestamp: :desc)
      render :reason_codes
    end
  end

  def destroy
    if @reason_code.soft_delete
      redirect_to reason_codes_path, notice: 'Reason code was successfully deleted.'
    else
      redirect_to reason_codes_path, notice: 'Failed to delete reason code. Contact IT for help.'
    end
  end

private

  def check_permission
    require_permission 'timeclock_records', 2
  end

  def set_reason_code
    @reason_code = ReasonCode.find(params[:id])
  end

  def reason_code_params
    params.require(:timeclock_record).permit(:code, :requires_notes, :is_deleted)
  end

end
