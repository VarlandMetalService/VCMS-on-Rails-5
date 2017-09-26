class EmployeeNotesController < ApplicationController
  before_action :set_note, only: [:edit, :update, :destroy]
  before_action :check_permission

  def index
    if @access_level.access_level == 3
      @employee_notes = EmployeeNote.all.page(params[:page])
    else
      @employee_notes = EmployeeNote.all.page(params[:page]).with_entered_by(current_user.id)
    end
  end

  def new
    @employee_note = EmployeeNote.new
  end

  def create
    @employee_note = EmployeeNote.new employee_note_params
    @employee_note.author = current_user
    @employee_note.ip_address = request.remote_ip
    if @employee_note.save
      redirect_to employee_notes_url
    else
      render 'new'
    end
  end

  def edit
  end

  def destroy
    if @employee_note.destroy
      redirect_to employee_notes_url, notice: 'Successfully deleted employee note.'
    else
      redirect_to employee_notes_url, flash: { error: 'Error deleting employee note. Please contact IT.' }
    end
  end

  def update
    if @employee_note.update employee_note_params
      redirect_to employee_notes_url, notice: 'Successfully updated employee note.'
    else
      render :edit
    end
  end

private

  def check_permission
    require_permission 'employee_notes', 2
  end

  def set_note
    @employee_note = EmployeeNote.find params[:id]
  end

  def employee_note_params
    params.require(:employee_note).permit(:employee, :note_on, :note_type, :notes, :follow_up, :follow_up_on)
  end
end
