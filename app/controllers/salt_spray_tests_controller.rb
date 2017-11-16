class SaltSprayTestsController < ApplicationController

  before_action :set_salt_spray_test, only: [:edit, :update, :show, :destroy]
  before_action :check_user_permission

  has_scope :sorted_by
  has_scope :with_shop_order_number
  has_scope :with_put_on_by
  has_scope :with_put_on_at_gte
  has_scope :with_put_on_at_lte
  has_scope :with_salt_spray_part_number

  def index
    @salt_spray_tests = apply_scopes(SaltSprayTest).all.page(params[:page]).where('pulled_off_at IS NULL')

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
  end

  def new
    @salt_spray_test = SaltSprayTest.new
    @salt_spray_test.build_salt_spray_part
  end

  def edit
  end

  def create
    @salt_spray_test = SaltSprayTest.new salt_spray_test_params

    if add_shop_order_details
      if @salt_spray_test.save
        redirect_to action: 'index'
      else
        render 'new'
      end
    else
      # Render "Unable to find shop order" modal
      respond_to do |format|
        format.js {render 'salt_spray_tests/manual_entry_modal.js.erb'}
      end
    end
  end

  def update
    case params[:commit]
    when 'White Spot Found'
      @salt_spray_test.update_spot(current_user.id, 'white')
    when 'Red Spot Found'
      @salt_spray_test.update_spot(current_user.id, 'red')
    when 'Test Complete'
      @salt_spray_test.pulled_off_at = Date.current
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

  def show
    @attachments = SaltSprayTest.find_by_id(params[:id]).attachments
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

  def add_shop_order_details
    shop_order_param = params[:salt_spray_test][:shop_order_number]

    if so_details = get_shop_order_details(shop_order_param)
      sub_from_api = so_details['sub']

      begin
        @salt_spray_test.customer = so_details['customer']
        @salt_spray_test.process_code = so_details['process']
        @salt_spray_test.part_number = so_details['part']
        if !params[:salt_spray_test][:sub].blank?
          if !sub_from_api.blank?
            @salt_spray_test.sub = params[:salt_spray_test][:sub] + ', ' + sub_from_api
          end
        else
          @salt_spray_test.sub = sub_from_api
        end
        @salt_spray_test.white_spec = so_details['saltSprayWhite']
        @salt_spray_test.red_spec = so_details['saltSprayRed']
        @salt_spray_test.part_area = so_details['pieceArea']
        @salt_spray_test.density = so_details['poundsPerCubic']
        @salt_spray_test.load_weight = so_details['loadWeight']

      rescue => e
        @salt_spray_test.errors.add(:salt_spray_test, "Invalid shop order number.")
      end
    else
      if !params[:salt_spray_test][:customer].blank?
        return true
      end
      return false
    end
  end

  def salt_spray_test_params
    params.require(:salt_spray_test).permit(:shop_order, :put_on_at, :pulled_off_at, :put_on_by, :barrel_number, :load_weight,
                                              :marked_red_at, :marked_white_at, :marked_red_by, :marked_white_by, :comments, :shop_order_number,
                                              :load_number, :customer, :process_code, :part_number, :sub, :part_area, :density, :white_spec, :red_spec,
                                              :dept, salt_spray_part_attributes: [:id],
                                              salt_spray_process_steps_attributes: [:id, :name, :_destroy],
                                              attachments_attributes: [:id, :content_type, :file, :_destroy])
  end

  def check_user_permission
    check_permission 'salt_spray_tests'
  end

  def set_salt_spray_test
    @salt_spray_test = SaltSprayTest.find params[:id]
  end

end
