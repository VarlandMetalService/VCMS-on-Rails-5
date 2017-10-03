class SaltSprayTestsController < ApplicationController

  before_action :set_salt_spray_test, only: [:edit, :update, :destroy]
  before_action :check_user_permission

  has_scope :sorted_by
  has_scope :with_salt_spray_part_id
  has_scope :with_shop_order_number
  has_scope :with_put_on_by
  has_scope :with_date_on_gte
  has_scope :with_date_on_lt

  def index
    @salt_spray_tests = apply_scopes(SaltSprayTest).all.page(params[:page]).where("is_archived = ?", false)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
  end

  def new
    @salt_spray_test = SaltSprayTest.new
  end

  def edit
    @white_hours = @salt_spray_test.calculate_rust_hours('white')
    @red_hours = @salt_spray_test.calculate_rust_hours('red')
  end

  def create
    new_shop_order = params[:salt_spray_test][:salt_spray_parts][:shop_order_number]
    new_load_number = params[:salt_spray_test][:salt_spray_parts][:load_number]
    new_sub = params[:salt_spray_test][:salt_spray_parts][:sub]
    new_customer = params[:salt_spray_test][:salt_spray_parts][:customer]
    new_process = params[:salt_spray_test][:salt_spray_parts][:process]
    new_part_number = params[:salt_spray_test][:salt_spray_parts][:part_number]
    new_white_spec = params[:salt_spray_test][:salt_spray_parts][:white_spec]
    new_red_spec = params[:salt_spray_test][:salt_spray_parts][:red_spec]
    new_part_area = params[:salt_spray_test][:salt_spray_parts][:part_area]
    new_ft_cubed_per_pound = params[:salt_spray_test][:salt_spray_parts][:ft_cubed_per_pound]

    @salt_spray_test = SaltSprayTest.new salt_spray_test_params
    @salt_spray_part = @salt_spray_test.build_salt_spray_part(:shop_order_number => new_shop_order,
                                                              :load_number => new_load_number, :sub => new_sub,
                                                              :customer => new_customer, :process => new_process, :part_number => new_part_number,
                                                              :white_spec => new_white_spec, :red_spec => new_red_spec,
                                                              :part_area => new_part_area, :ft_cubed_per_pound => new_ft_cubed_per_pound)

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
      @salt_spray_test.date_off = DateTime.current
      @salt_spray_test.is_archived = true
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
    @salt_spray_part = SaltSprayPart.find params[:id]
  end

  def test_complete
    respond_to do |format|
      format.html
      format.js
    end
  end

  def archived_tests
    @salt_spray_tests = apply_scopes(SaltSprayTest).all.page(params[:page]).where('is_archived = ?', true)

    respond_to do |format|
      format.html
      format.js
    end
  end

private

  def add_shop_order_details
    shop_order_param = params[:salt_spray_test][:salt_spray_parts][:shop_order_number]

    if so_details = get_shop_order_details(shop_order_param)
      sub_from_api = so_details['sub']

      my_logger.debug "so_details = " + so_details.to_s
      my_logger.debug "sub = " + params[:salt_spray_test][:salt_spray_parts][:sub]

      begin
        @salt_spray_part.customer = so_details['customer']
        @salt_spray_part.process = so_details['process']
        @salt_spray_part.part_number = so_details['part']
        if !params[:salt_spray_test][:salt_spray_parts][:sub].blank?
          if !sub_from_api.blank?
            @salt_spray_part.sub = params[:salt_spray_test][:salt_spray_parts][:sub] + ', ' + sub_from_api
          end
        else
          @salt_spray_part.sub = sub_from_api
        end
        @salt_spray_part.white_spec = so_details['saltSprayWhite']
        @salt_spray_part.red_spec = so_details['saltSprayRed']
        @salt_spray_part.part_area = so_details['pieceArea']
        @salt_spray_part.ft_cubed_per_pound = so_details['poundsPerCubic']

        @salt_spray_part.save

        @salt_spray_test.salt_spray_part_id = @salt_spray_part.id
        @salt_spray_test.load_weight = so_details['loadWeight']

      rescue => e
        @salt_spray_test.errors.add(:salt_spray_test, "Invalid shop order number.")
        my_logger.error "Failed to find part information from shop order number - " + e.to_s
      end
    else
      if !params[:salt_spray_test][:salt_spray_parts][:customer].blank?
        @salt_spray_part.save
        return true
      end
      return false
    end
  end

  def salt_spray_test_params
    params.require(:salt_spray_test).permit(:checked, :shop_order, :dept, :date_on, :date_off, :is_archived,
                                              :put_on_by, :barrel_number, :load_weight, :date_w_red, :date_w_white, :who_called_red, :who_called_white, :comments,
                                              {salt_spray_parts_attributes: [:id, :shop_order_number, :load_number, :sub, :customer, :process,
                                              :part_number, :load_weight, :white_spec, :red_spec, :part_area, :ft_cubed_per_pound]},
                                              salt_spray_process_steps_attributes: [:id, :name, :_destroy],
                                              attachments_attributes: [:id, :content_type, :file, :_destroy])
  end

  def set_salt_spray_test
    @salt_spray_test = SaltSprayTest.find params[:id]
  end

  def check_user_permission
    check_permission 'employee_notes'
  end

end
