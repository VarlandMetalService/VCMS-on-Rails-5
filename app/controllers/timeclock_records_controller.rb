class TimeclockRecordsController < ApplicationController
  before_action :set_timeclock_record, only: [:show, :edit, :update, :destroy]

  # GET /timeclock_records
  def index
    @timeclock_records = TimeclockRecord.all
    @flagged_records = TimeclockRecord.all.where('is_flagged = ?', true)
  end

  # GET /timeclock_records/1
  def show
  end

  # GET /timeclock_records/new
  def new
    @timeclock_record = TimeclockRecord.new
  end

  # GET /timeclock_records/1/edit
  def edit
  end

  # POST /timeclock_records
  def create
    @timeclock_record = TimeclockRecord.new(timeclock_record_params)

    if @timeclock_record.save
      redirect_to @timeclock_record, notice: 'Timeclock record was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /timeclock_records/1
  def update
    if @timeclock_record.update(timeclock_record_params)
      redirect_to @timeclock_record, notice: 'Timeclock record was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /timeclock_records/1
  def destroy
    @timeclock_record.destroy
    redirect_to timeclock_records_url, notice: 'Timeclock record was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_timeclock_record
      @timeclock_record = TimeclockRecord.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def timeclock_record_params
      params.fetch(:timeclock_record, {})
    end
end
