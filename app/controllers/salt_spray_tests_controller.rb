class SaltSprayTestsController < ApplicationController

  before_action :set_salt_spray_test, only: [:edit, :update, :destroy]
  before_action :check_user_permission

  has_scope :sorted_by
  has_scope :with_shop_order_number
  has_scope :with_put_on_by
  has_scope :with_date_on_gte
  has_scope :with_date_on_lte
  has_scope :with_salt_spray_part_number

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
      @salt_spray_test.date_off = Date.current
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
    @attachments = SaltSprayTest.find_by_id(params[:id]).attachments
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
    shop_order_param = params[:salt_spray_test][:salt_spray_part_attributes][:shop_order_number]

    if so_details = get_shop_order_details(shop_order_param)
      sub_from_api = so_details['sub']

      begin
        @salt_spray_test.salt_spray_part.customer = so_details['customer']
        @salt_spray_test.salt_spray_part.process = so_details['process']
        @salt_spray_test.salt_spray_part.part_number = so_details['part']
        if !params[:salt_spray_test][:salt_spray_part_attributes][:sub].blank?
          if !sub_from_api.blank?
            @salt_spray_test.salt_spray_part.sub = params[:salt_spray_test][:salt_spray_part_attributes][:sub] + ', ' + sub_from_api
          end
        else
          @salt_spray_test.salt_spray_part.sub = sub_from_api
        end
        @salt_spray_test.salt_spray_part.white_spec = so_details['saltSprayWhite']
        @salt_spray_test.salt_spray_part.red_spec = so_details['saltSprayRed']
        @salt_spray_test.salt_spray_part.part_area = so_details['pieceArea']
        @salt_spray_test.salt_spray_part.ft_cubed_per_pound = so_details['poundsPerCubic']
        @salt_spray_test.salt_spray_part.load_weight = so_details['loadWeight']

      rescue => e
        @salt_spray_test.errors.add(:salt_spray_test, "Invalid shop order number.")
      end
    else
      if !params[:salt_spray_test][:salt_spray_part_attributes][:customer].blank?
        return true
      end
      return false
    end
  end

  def salt_spray_test_params
    params.require(:salt_spray_test).permit(:checked, :shop_order, :date_on, :date_off, :is_archived,
                                              :put_on_by, :barrel_number, :load_weight, :date_w_red, :date_w_white, :who_called_red, :who_called_white, :comments,
                                              salt_spray_part_attributes: [:id, :shop_order_number, :load_number, :sub, :customer, :process,
                                              :part_number, :load_weight, :dept, :white_spec, :red_spec, :part_area, :ft_cubed_per_pound],
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
