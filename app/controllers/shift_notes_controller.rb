class ShiftNotesController < ApplicationController
  before_action :set_note, only: [:edit, :update, :destroy]
  before_action :check_permission

  has_scope :search_query
  has_scope :with_date
  has_scope :with_shift
  has_scope :with_entered_by
  has_scope :with_department
  has_scope :with_note_type
  has_scope :sorted_by

  def index
    @shift_notes = apply_scopes(ShiftNote).all.page(params[:page])
  end

  def new
    @shift_note = ShiftNote.new
  end

  def create
    @shift_note = ShiftNote.new shift_note_params
    @shift_note.author = current_user
    @shift_note.ip_address = request.remote_ip
    if @shift_note.save
      redirect_to shift_notes_url
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @shift_note.supervisor_notes != shift_note_params[:supervisor_notes]
      @shift_note.store_supervisor_info @current_user
    end
    if @shift_note.update shift_note_params
      redirect_to shift_notes_url, notice: 'Successfully updated shift note.'
    else
      render :edit
    end
  end

  def destroy
    if @shift_note.destroy
      redirect_to shift_notes_url, notice: 'Successfully deleted shift note.'
    else
      redirect_to shift_notes_url, flash: { error: 'Error deleting shift note. Please contact IT.' }
    end
  end

private

  def check_permission
    require_permission 'shift_notes', 2
  end

  def set_note
    @shift_note = ShiftNote.find params[:id]
  end

  def shift_note_params
    params.require(:shift_note).permit(:note_on, :shift, :department, :note_type, :notes, :supervisor_notes, attachments_attributes: [:id, :content_type, :file, :_destroy])
  end
end
