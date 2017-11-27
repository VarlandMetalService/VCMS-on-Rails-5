class CategoriesController < ApplicationController
  before_action :check_permission
  before_action :set_category, only: [:edit, :update, :move_up, :move_down]

  def edit
  end

  def create
    @category = Category.new category_params
    if @category.save
      redirect_to documents_url, notice: "Successfully added <code>#{@category.name}</code>.".html_safe
    else
      redirect_to documents_url, flash: { error: "Error adding <code>#{@category.name}</code>. Please try again or contact IT for help.".html_safe }
    end
  end

  def update
    if @category.update category_params
      redirect_to documents_path
    else
      render :edit
    end
  end

  def move_up
    @category.move_up
    redirect_to documents_url
  end

  def move_down
    @category.move_down
    redirect_to documents_url
  end

private

  def check_permission
    require_permission 'documents', 3
  end

  def set_category
    @category = Category.find params[:id]
  end

  def category_params
    params.require(:category).permit(:name, :parent_id, :google_drive_folder)
  end

end
