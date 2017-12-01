class SaltSprayTestsController < ApplicationController
  before_action :check_user_permission
  before_action :set_salt_spray_test, only: [:show, :edit, :update, :destroy, :add_comment]

  has_scope :with_shop_order_number
  has_scope :with_put_on_by
  has_scope :with_part_number
  has_scope :with_put_on_at_gte
  has_scope :with_put_on_at_lte
  has_scope :sorted_by

  def index
    @salt_spray_tests = apply_scopes(SaltSprayTest).all.page(params[:page]).where('pulled_off_at IS NULL')

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @attachments = SaltSprayTest.find_by_id(params[:id]).attachments
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
    # For mobile submit
    case params[:commit]
    when 'White Spot Found'
      @salt_spray_test.update_spot(current_user.id, 'white')
    when 'Red Spot Found'
      @salt_spray_test.update_spot(current_user.id, 'red')
    when 'Test Complete'
      @salt_spray_test.pulled_off_at = Date.current
      @salt_spray_test.pulled_off_by = current_user.id
    end

    if @salt_spray_test.update(salt_spray_test_params)
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    if @access_level.access_level == 3
      if @salt_spray_test.delete_test(current_user.id)
        redirect_to salt_spray_tests_path, notice: 'Successfully deleted salt spray test.'
      else
        redirect_to salt_spray_tests_path, flash: { error: 'Error deleting salt spray test. Please contact IT.' }
      end
    else
      redirect_to salt_spray_tests_path, flash: { error: 'You do not have permission to delete salt spray tests.' }
    end
  end

  def add_comment
    @salt_spray_test.comments.build
  end

  def test_complete
    respond_to do |format|
      format.html
      format.js
    end
  end

  def archived_tests
    @salt_spray_tests = apply_scopes(SaltSprayTest).all.page(params[:page]).where('pulled_off_at IS NOT NULL')

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
    @salt_spray_test = SaltSprayTest.find params[:id]
  end

  def salt_spray_test_params
    params.require(:salt_spray_test).permit(:shop_order, :put_on_at, :pulled_off_at, :put_on_by, :pulled_off_by,
                                            :barrel_number, :marked_red_at, :marked_white_at, :marked_red_by, :marked_white_by,
                                            :shop_order_number, :load_number, :customer, :process_code, :part_number, :sub,
                                            :load_weight, :part_area, :density, :white_spec, :red_spec, :dept, :is_sample,
                                            salt_spray_process_steps_attributes: [:id, :name, :_destroy],

                                            comments_attributes: [:id, :content, :_destroy])
                                            # attachments_attributes: [:id, :content_type, :file, :_destroy],
  end

end
