class SaltSprayTestsController < ApplicationController
  before_action :check_user_permission
  before_action :set_salt_spray_test, only: [:show, :edit, :update, :destroy, :add_comment, :edit_comment, :show_comments, :delete_comment]
  before_action :set_other_field_values, only: :edit
  after_action :cache_filters, only: [:index, :archived_tests]

  has_scope :with_shop_order_number
  has_scope :with_put_on_by
  has_scope :with_pulled_off_by
  has_scope :with_customer
  has_scope :with_part_number
  has_scope :with_process_code
  has_scope :with_flag
  has_scope :with_sample
  has_scope :with_has_comments
  has_scope :with_has_attachments
  has_scope :with_comments
  has_scope :with_sub
  has_scope :with_put_on_at_gte
  has_scope :with_put_on_at_lte
  has_scope :with_pulled_off_at_gte
  has_scope :with_pulled_off_at_lte
  has_scope :with_marked_white_at_gte
  has_scope :with_marked_white_at_lte
  has_scope :with_marked_white_by
  has_scope :with_marked_red_at_gte
  has_scope :with_marked_red_at_lte
  has_scope :with_marked_red_by
  has_scope :sorted_by

  def index
    @salt_spray_tests = apply_scopes(SaltSprayTest).active.order(checked_by: :asc, process_code: :desc)
    @recently_archived_tests = apply_scopes(SaltSprayTest).archived.where("pulled_off_at >= ? AND pulled_off_at <= ?", DateTime.now.beginning_of_day, DateTime.now.end_of_day)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @comments = SaltSprayTest.find_by_id(params[:id]).comments
  end

  def new
    @salt_spray_test = SaltSprayTest.new
  end

  def edit
  end

  def create
    @salt_spray_test = SaltSprayTest.new salt_spray_test_params

    if @salt_spray_test.save
      redirect_to action: 'edit', id: @salt_spray_test.id
    else
      render 'new'
    end
  end

  def update
    check_for_mobile(params)
    check_param_values(params)

    if @salt_spray_test.update(salt_spray_test_params)
      if params[:salt_spray_test][:on_archived] == 'true'
        redirect_to action: 'archived_tests', params: session[:params]
      else
        if @salt_spray_test.pulled_off_at
          flash[:notice] = "#{@salt_spray_test.shop_order_number} has been archived."
        end
        redirect_to action: 'index', params: session[:params]
      end
    else
      render 'edit'
    end
  end

  def destroy
    if @access_level.access_level == 3
      if @salt_spray_test.delete_test(current_user.id)
        redirect_to salt_spray_tests_path(session[:params]), notice: 'Successfully deleted salt spray test.'
      else
        redirect_to salt_spray_tests_path(session[:params]), flash: { error: 'Error deleting salt spray test. Please contact IT.' }
      end
    else
      redirect_to salt_spray_tests_path(session[:params]), flash: { error: 'You do not have permission to delete salt spray tests.' }
    end
  end

  def add_comment
  end

  def edit_comment
    @comment = @salt_spray_test.comments.find(params[:comment_id])
  end

  def show_comments
  end

  def delete_comment
    @comment = @salt_spray_test.comments.find(params[:comment_id])
    if @access_level.access_level == 3
      if @comment.destroy
        redirect_to salt_spray_tests_path(session[:params]), notice: 'Successfully deleted comment.'
      else
        redirect_to salt_spray_tests_path(session[:params]), flash: { error: 'Error deleting comment. Please contact IT.' }
      end
    else
      redirect_to salt_spray_tests_path(session[:params]), flash: { error: 'You do not have permission to delete comments.' }
    end
  end

  def test_complete
    respond_to do |format|
      format.html
      format.js
    end
  end

  def archived_tests
    @salt_spray_tests = apply_scopes(SaltSprayTest).archived.page(params[:page]).order(put_on_at: :desc)

    respond_to do |format|
      format.html
      format.js
    end
  end

private

  def check_user_permission
    check_permission 'salt_spray_tests'
  end

  def set_salt_spray_test
    begin
      @salt_spray_test = SaltSprayTest.find params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Unable to find record. Refreshed record list."
      redirect_to action: 'index'
    end
  end

  def salt_spray_test_params
    params.require(:salt_spray_test).permit(:shop_order_number, :load_number, :customer, :process_code, :part_number, :sub,
                                            :part_area, :density, :white_spec, :red_spec, :dept, :load_weight,
                                            :put_on_by, :put_on_at, :pulled_off_at, :pulled_off_by, :manual_edit,
                                            :marked_white_at, :marked_white_by, :marked_red_at, :marked_red_by,
                                            :flagged_by, :checked_by, :checked_by_archive, :is_sample, :sample_code,
                                            salt_spray_process_steps_attributes: [:id, :chromate, :top_coat, :chromate_other, :top_coat_other, :thickness, :dipping_time, :note, :_destroy],
                                            comments_attributes: [:id, :content, :created_by, :_destroy, attachments_attributes: [:id, :content_type, :file, :_destroy]])
  end

  def cache_filters
    session[:params] = params
  end

  def check_param_values(params)
    @salt_spray_test.flagged_by = nil if params[:salt_spray_test][:remove_flag] == "1"

    # If no marked_by value is selected when marked_at is updated, set value to current user
    if params[:salt_spray_test][:marked_white_at].present? && params[:salt_spray_test][:marked_white_by].blank?
      params[:salt_spray_test][:marked_white_by] = current_user.id
    end
    if params[:salt_spray_test][:marked_red_at].present? && params[:salt_spray_test][:marked_red_by].blank?
      params[:salt_spray_test][:marked_red_by] = current_user.id
    end
  end

  def set_other_field_values
    @salt_spray_test.salt_spray_process_steps.each do |process_step|

      # If 'Other' is selected in process steps, ensure the data is correctly displayed in the form
      if process_step.chromate.present? && !in_nested_array?(process_step.chromate, SaltSprayProcessStep.options_for_chromate)
        process_step.chromate_other = process_step.chromate
        process_step.chromate = "Other"
      end
      if process_step.top_coat.present? && !in_nested_array?(process_step.top_coat, SaltSprayProcessStep.options_for_top_coat)
        process_step.top_coat_other = process_step.top_coat
        process_step.top_coat = "Other"
      end

    end
  end

  def check_for_mobile(params)
    if params[:mark_white]
      @salt_spray_test.update_spot(current_user.id, 'white')
    elsif params[:mark_red]
      @salt_spray_test.update_spot(current_user.id, 'red')
    elsif params[:test_complete]
      params[:salt_spray_test][:pulled_off_at] = DateTime.current
      params[:salt_spray_test][:pulled_off_by] = current_user.id
    end
  end

end
